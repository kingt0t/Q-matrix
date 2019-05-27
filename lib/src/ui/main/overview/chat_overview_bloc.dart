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

import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/overview/models/chat_overview.dart';
import 'package:pattle/src/ui/util/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pattle/src/di.dart' as di;
import 'package:pattle/src/ui/main/sync_bloc.dart';

final bloc = ChatOverviewBloc();

class ChatOverviewBloc {
  
  PublishSubject<List<ChatOverview>> _chatsSubj = PublishSubject<List<ChatOverview>>();
  Observable<List<ChatOverview>> get chats => _chatsSubj.stream;

  final LocalUser _user = di.getLocalUser();

  Future<void> loadChats() async {
    var chats = List<ChatOverview>();

    // Get all rooms and push them as a single list
    await for(Room room in _user.rooms.all()) {
      final latestEvent = await room.timeline.upTo(20, allowRemote: false)
          .firstWhere((event) => event is! RedactionEvent, orElse: () => null);

      var latestEventForSorting = await room.timeline.upTo(20, allowRemote: false)
          .firstWhere(
            (event) =>
              (event is! MemberChangeEvent
               || event is JoinEvent && event.content.subjectId == _user.id)
            && event is! RedactionEvent,
            orElse: () => null
          );

      // If there is no non-MemberChangeEvent in the last
      // 10 messages, just settle for the most recent one (which ever
      // type it is).
      if (latestEventForSorting == null) {
        latestEventForSorting = latestEvent;
      }

      final chat = ChatOverview(
        room: room,
        name: room.name,
        latestEvent: latestEvent,
        latestEventForSorting: latestEventForSorting
      );

      chats.add(chat);
    }

    chats.sort((a, b) {
      if (a.latestEventForSorting != null && b.latestEventForSorting != null) {
        return a.latestEventForSorting.time.compareTo(b.latestEventForSorting.time);
      } else if (a.latestEventForSorting != null && b.latestEventForSorting == null) {
        return 1;
      } else if (a.latestEventForSorting == null && b.latestEventForSorting != null) {
        return -1;
      } else {
        return 0;
      }
    });
    _chatsSubj.add(List.of(chats.reversed));
  }

  Future<void> startSync() async {
    // Load from store before sync
    await loadChats();

    syncBloc.start();

    syncBloc.stream.listen((success) async => await loadChats());
  }
}
