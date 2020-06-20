// Copyright (C) 2019  Nathan van Beelen (CLA signed)
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

import '../../../../models/chat_message.dart';
import '../../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'state.dart';
export 'event.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final Matrix _matrix;
  Room _room;

  StreamSubscription _sub;

  MediaBloc(this._matrix, RoomId roomId) : _room = _matrix.user.rooms[roomId] {
    _sub = _room.updates.listen((update) {
      _room = update.user.rooms[_room.id];
      add(FetchImages());
    });
  }

  @override
  MediaState get initialState => _loadImages();

  @override
  Stream<MediaState> mapEventToState(MediaEvent event) async* {
    if (event is FetchImages) {
      yield _loadImages();
    }
  }

  MediaState _loadImages() {
    final imageMessageEvents = <RoomEvent>[];

    for (final event in _room.timeline) {
      if (event is ImageMessageEvent || event is VideoMessageEvent) {
        imageMessageEvents.add(event);
      }
    }

    return MediaState(
      imageMessageEvents
          .map(
            (i) => ChatMessage(
              _room,
              i,
              isMe: (id) => id == _matrix.user.id,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> close() async {
    await super.close();
    await _sub.cancel();
  }
}
