// Copyright (C) 2019  Wilko Manger
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

import 'package:bloc/bloc.dart';

import '../models/channel.dart';

import '../../../../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  final Matrix _matrix;
  final Channel _channel;

  ChannelBloc(this._matrix, this._channel);

  @override
  ChannelState get initialState => NotJoined();

  @override
  Stream<ChannelState> mapEventToState(ChannelEvent event) async* {
    if (event is Join) {
      yield Joining();

      await _matrix.user.rooms.enter(
        id: _channel.roomId,
        through: _channel.server,
      );

      yield Joined(_channel.roomId);
    }
  }
}
