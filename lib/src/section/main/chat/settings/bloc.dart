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

import '../../../../models/chat_member.dart';

import '../../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class ChatSettingsBloc extends Bloc<ChatSettingsEvent, ChatSettingsState> {
  final Matrix _matrix;
  Room _room;

  ChatSettingsBloc(this._matrix, RoomId roomId)
      : _room = _matrix.user.rooms[roomId];

  @override
  ChatSettingsState get initialState => _loadMembers();

  @override
  Stream<ChatSettingsState> mapEventToState(ChatSettingsEvent event) async* {
    if (event is FetchMembers) {
      yield MembersLoading(state.members);

      if ((!event.all && _room.members.length < 6) ||
          (event.all &&
              _room.members.length != _room.summary.joinedMembersCount)) {
        final update = await _room.memberTimeline.load(
          count: !event.all ? 6 : null,
        );
        _room = update.user.rooms[_room.id];
      }

      yield _loadMembers();
    }
  }

  ChatSettingsState _loadMembers() {
    var members = List.of(_room.members);

    members = members.where((m) => m.membership is Joined).toList();

    final me = _room.members[_matrix.user.id];
    members.remove(me);
    members.insert(0, me);

    return MembersLoaded(
      members
          .map(
            (u) => ChatMember.fromRoomAndUserId(
              _room,
              u.id,
              isMe: _matrix.user.id == u.id,
            ),
          )
          .toList(),
    );
  }
}
