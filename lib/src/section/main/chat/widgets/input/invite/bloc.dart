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
import 'package:matrix_sdk/matrix_sdk.dart' hide Joined;

import '../../../../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'state.dart';
export 'event.dart';

class InviteInputBloc extends Bloc<InviteInputEvent, InviteInputState> {
  // Doesn't need the most up to date room instance.
  final Room _room;

  InviteInputBloc(
    Matrix matrix,
    RoomId roomId,
  ) : _room = matrix.chats[roomId].room;

  @override
  InviteInputState get initialState => NotAccepted();

  @override
  Stream<InviteInputState> mapEventToState(InviteInputEvent event) async* {
    if (event is AcceptInvite) {
      yield Accepting();
      await _room.join();
      yield Accepted();
    }

    if (event is RejectInvite) {
      yield Rejecting();
      await _room.leave();
      yield Rejected();
    }
  }
}
