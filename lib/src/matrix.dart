// Copyright (C) 2020  Wilko Manger
// Copyright (C) 2020  Cyril Dutrieux <cyril@cdutrieux.fr>
//
// This file is part of Pattle.
//
// Pattle is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pattle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Pattle.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as path;

import 'chat_order/bloc.dart';
import 'auth/bloc.dart';
import 'models/chat.dart';

class Matrix {
  static MoorStore _store;
  static MoorStore get store => _store;

  static Future<MoorStoreLocation> get storeLocation async {
    final dataDir = await getApplicationDocumentsDirectory();

    return MoorStoreLocation.file(
      File(path.join(dataDir.path, 'pattle.sqlite')),
    );
  }

  // Used for listening to auth state changes
  final AuthBloc _authBloc;

  // Notified when chats changed.
  final ChatOrderBloc _chatOrderBloc;

  MyUser _user;
  MyUser get user => _user;

  var _firstSyncCompleter = Completer<void>();
  Future<void> get firstSync => _firstSyncCompleter.future;

  var _userAvailable = Completer<void>();
  Future<void> get userAvaible => _userAvailable.future;

  var _chats = <RoomId, Chat>{};
  Map<RoomId, Chat> get chats => _chats;

  Matrix(this._authBloc, this._chatOrderBloc) {
    _authBloc.listen(_processAuthState);
  }

  Future<void> logout() async {
    // Reset completers
    _userAvailable = Completer<void>();
    _firstSyncCompleter = Completer<void>();

    await _user.logout();

    final temp = await getTemporaryDirectory();
    final data = await getApplicationDocumentsDirectory();

    await temp.delete(recursive: true);
    await data.delete(recursive: true);
  }

  Future<void> _processAuthState(AuthState state) async {
    if (state is Authenticated) {
      _processUser(state.user);
      _userAvailable.complete();
      _user.startSync();

      await _user.updates.firstSync.then(_processUpdate);
      _firstSyncCompleter.complete();

      _user.updates.listen(_processUpdate);
    }

    if (state is NotAuthenticated) {
      _user?.stopSync();
      _user = null;
    }
  }

  void _processUser(MyUser user, {MyUser delta, bool wasTimelineLoad = false}) {
    _user = user;

    _chats = Map.fromEntries(
      _user.rooms.where((r) => !r.isUpgraded).map(
            (r) => MapEntry(
              r.id,
              r.toChat(
                myId: _user.id,
                delta: delta != null ? delta.rooms[r.id] : null,
                wasTimelineLoad: wasTimelineLoad,
              ),
            ),
          ),
    );
  }

  void _processUpdate(Update update) {
    final requestType = update is RequestUpdate ? update.type : null;

    _processUser(
      update.user,
      delta: update.delta,
      wasTimelineLoad: requestType == RequestType.loadRoomEvents,
    );

    final notChannels = _chats.values.notChannels.toList();
    final channels = _chats.values.channels.toList();
    _chatOrderBloc.add(
      RemoveChats(
        personal: channels,
        public: notChannels,
      ),
    );
    _chatOrderBloc.add(
      UpdateChatOrder(
        personal: notChannels,
        public: channels,
      ),
    );

    _chatUpdatesController.add(
      ChatsUpdate(
        chats: _chats,
        // TODO: Add toMap in SDK
        delta: Map.fromEntries(
          update.delta.rooms?.map((room) => MapEntry(room.id, room)) ?? [],
        ),
        type: update is RequestUpdate ? update.type : null,
      ),
    );
  }

  final _chatUpdatesController = StreamController<ChatsUpdate>.broadcast();

  Stream<ChatsUpdate> get updates => _chatUpdatesController.stream;

  Stream<ChatUpdate> updatesFor(RoomId roomId) => _chatUpdatesController.stream
      .map(
        (update) => ChatUpdate(
          chat: update.chats[roomId],
          delta: update.delta[roomId],
          type: update.type,
        ),
      )
      .where((update) => update.delta != null);

  static Matrix of(BuildContext context) => Provider.of<Matrix>(
        context,
        listen: false,
      );
}

@immutable
class ChatsUpdate {
  final Map<RoomId, Chat> chats;
  final Map<RoomId, Room> delta;

  final RequestType type;

  ChatsUpdate({
    @required this.chats,
    @required this.delta,
    @required this.type,
  });
}

class ChatUpdate {
  final Chat chat;
  final Room delta;

  final RequestType type;

  ChatUpdate({
    @required this.chat,
    @required this.delta,
    @required this.type,
  });
}
