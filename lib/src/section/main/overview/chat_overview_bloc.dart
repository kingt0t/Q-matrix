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
import 'package:rxdart/rxdart.dart';
import 'package:pattle/src/di.dart' as di;

import '../../../sync_bloc.dart';
import '../../../util/room.dart';
import 'models/chat_overview.dart';

final bloc = ChatOverviewBloc();

class ChatOverviewBloc {
  final _chatsSubj = PublishSubject<List<ChatOverview>>();
  Stream<List<ChatOverview>> get personalChats =>
      _chatsSubj.stream.flatMapIterable(
        (list) => Stream.value([
          list
              .where((chat) =>
                  chat.room.aliases == null || chat.room.aliases.isEmpty)
              .toList()
        ]),
      );

  Stream<List<ChatOverview>> get publicChats =>
      _chatsSubj.stream.flatMapIterable(
        (list) => Stream.value([
          list
              .where((chat) =>
                  chat.room.aliases != null && chat.room.aliases.isNotEmpty)
              .toList(),
        ]),
      );

  final LocalUser _user = di.getLocalUser();

  Future<void> loadChats() async {
    final chats = List<ChatOverview>();

    // Get all rooms and push them as a single list
    for (Room room in await _user.rooms.get()) {
      // Don't show rooms that have been upgraded
      if (room.isUpgraded) {
        continue;
      }

      final ignoredEvents = ignoredEventsOf(room, isOverview: true);

      // TODO: Add optional filter argument to up to call
      final latestEvent =
          (await room.timeline.get(upTo: 10, allowRemote: false)).firstWhere(
        (event) => !ignoredEvents.contains(event.runtimeType),
        orElse: () => null,
      );

      var latestEventForSorting =
          (await room.timeline.get(upTo: 10, allowRemote: false)).firstWhere(
        (event) =>
            (event is! MemberChangeEvent ||
                (event is JoinEvent &&
                    event is! DisplayNameChangeEvent &&
                    event is! AvatarChangeEvent &&
                    event.subject.id == _user.id)) &&
            event is! RedactionEvent,
        orElse: () => null,
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
        latestEventForSorting: latestEventForSorting,
      );

      chats.add(chat);
    }

    chats.sort((a, b) {
      if (a.room.highlightedUnreadNotificationCount > 0 &&
          b.room.highlightedUnreadNotificationCount <= 0) {
        return 1;
      } else if (a.room.highlightedUnreadNotificationCount <= 0 &&
          b.room.highlightedUnreadNotificationCount > 0) {
        return -1;
      } else if (a.room.totalUnreadNotificationCount > 0 &&
          b.room.totalUnreadNotificationCount <= 0) {
        return 1;
      } else if (a.room.totalUnreadNotificationCount <= 0 &&
          b.room.totalUnreadNotificationCount > 0) {
        return -1;
      } else if (a.latestEventForSorting != null &&
          b.latestEventForSorting != null) {
        return a.latestEventForSorting.time.compareTo(
          b.latestEventForSorting.time,
        );
      } else if (a.latestEventForSorting != null &&
          b.latestEventForSorting == null) {
        return 1;
      } else if (a.latestEventForSorting == null &&
          b.latestEventForSorting != null) {
        return -1;
      } else {
        return 0;
      }
    });
    _chatsSubj.add(List.of(chats.reversed));
  }

  Future<void> loadAndListen() async {
    await loadChats();

    syncBloc.stream.listen((state) async => await loadChats());
  }
}
