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
import 'package:matrix_sdk/matrix_sdk.dart';

import '../../../../../../../matrix.dart';
import '../../../../../../../chat_order/bloc.dart';

import 'event.dart';
import '../../models/channel.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class ChannelListBloc extends Bloc<ChannelListEvent, ChannelListState> {
  final Matrix _matrix;
  final ChatOrderBloc _chatOrderBloc;

  ChannelListBloc(this._matrix, this._chatOrderBloc)
      : _myPublicRooms = PublicRooms.of(_matrix.user.context.homeserver);

  @override
  ChannelListState get initialState => ChannelListState();

  ChannelListState _latestNonSearchState;

  Homeserver __extraHomeserver;
  Future<Homeserver> get _extraHomeserver async {
    if (__extraHomeserver == null) {
      __extraHomeserver = await Homeserver.fromWellKnown(
        Uri.parse('https://matrix.org'),
      );
    }

    return __extraHomeserver;
  }

  PublicRooms _myPublicRooms;

  PublicRooms _extraPublicRooms;

  @override
  Stream<ChannelListState> mapEventToState(ChannelListEvent event) async* {
    if (event is GetChannels) {
      var state = this.state;

      if (event.searchTerm != _myPublicRooms.searchTerm) {
        // Reset if searching for something different or not searching anymore
        _myPublicRooms = PublicRooms.of(_matrix.user.context.homeserver);
        _extraPublicRooms = PublicRooms.of(await _extraHomeserver);

        if (event.searchTerm == null && _latestNonSearchState != null) {
          yield _latestNonSearchState;
        }

        state = initialState;
      }

      final currentIsMine = _myPublicRooms.canLoadMore;

      var currentPublicRooms = currentIsMine
          ? _myPublicRooms
          : _extraPublicRooms ??= PublicRooms.of(await _extraHomeserver);

      if (currentPublicRooms.canLoadMore) {
        currentPublicRooms = await currentPublicRooms.load(
          as: _matrix.user,
          searchTerm: event.searchTerm,
        );

        if (currentIsMine) {
          _myPublicRooms = currentPublicRooms;
        } else {
          _extraPublicRooms = currentPublicRooms;
        }

        final allJoinedIds = _chatOrderBloc.state.public.entries
            .where((e) => e.value.membership is Joined)
            .map((e) => e.key)
            .followedBy(
              _chatOrderBloc.state.personal.entries
                  .where((e) => e.value.membership is Joined)
                  .map((e) => e.key),
            );

        final channels = currentPublicRooms
            .where((r) => !allJoinedIds.contains(r.id))
            .map((r) => r.toChannel(currentPublicRooms.server))
            .toList();

        final newState = currentIsMine
            ? state.copyWith(
                myChannels: (state.myChannels ?? []) + channels,
              )
            : state.copyWith(
                extraChannels: (state.extraChannels ?? []) + channels,
              );

        yield newState;

        if (event.searchTerm == null) {
          // Cache latest non search state
          _latestNonSearchState = newState;
        }

        // Load more if we're done with our rooms
        if (currentIsMine && !currentPublicRooms.canLoadMore) {
          add(GetChannels(event.searchTerm));
        }
      }
    }
  }
}
