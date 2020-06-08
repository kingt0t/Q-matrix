// Copyright (C) 2020  Wilko Manger
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

import 'package:bloc/bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pedantic/pedantic.dart';
import 'package:meta/meta.dart';

import '../../../models/chat.dart';

import '../../../matrix.dart';

import '../../../notifications/bloc.dart';

import 'event.dart';
import 'state.dart';

export 'state.dart';
export 'event.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const _pageSize = 30;

  final Matrix _matrix;
  final NotificationsBloc _notificationsBloc;

  Chat _chat;
  Room get _room => _chat.room;

  StreamSubscription _syncSub;

  ChatBloc(
    this._matrix,
    this._notificationsBloc,
    RoomId roomId,
  ) : _chat = _matrix.chats[roomId] {
    _syncSub = _matrix.updatesFor(roomId).listen((update) {
      _chat = update.chat;
      add(RefreshChat(chat: _chat));
    });
  }

  MyUser get me => _matrix.user;

  @override
  ChatState get initialState => _processChat(chat: _chat);

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is LoadMoreFromTimeline) {
      _room.timeline.load(count: _pageSize);
      return;
    }

    if (event is RefreshChat) {
      yield _processChat(chat: event.chat);
    }

    if (event is MarkAsRead) {
      _markAllAsRead();
    }
  }

  ChatState _processChat({
    @required Chat chat,
  }) {
    if (!chat.endReached &&
        chat.messages.length + chat.newMessages.length < _pageSize) {
      add(LoadMoreFromTimeline());
    }

    return ChatState(
      chat: chat,
    );
  }

  Future<void> _markAllAsRead() async {
    final id = _room.timeline
        .firstWhere(
          (e) => e.sentState != SentState.unsent,
          orElse: () => null,
        )
        ?.id;

    if (id != null) {
      _notificationsBloc.add(RemoveNotifications(roomId: _room.id, until: id));
      unawaited(_room.markRead(until: id));
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _syncSub.cancel();
  }
}
