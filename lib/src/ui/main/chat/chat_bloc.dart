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
import 'package:pattle/src/ui/main/models/chat_item.dart';
import 'package:pattle/src/ui/main/sync_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ChatBloc {

  JoinedRoom room;

  int _eventCount = 50;

  PublishSubject<bool> _isLoadingEventsSubj = PublishSubject<bool>();
  Stream<bool> get isLoadingEvents => _isLoadingEventsSubj.stream.distinct();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    if (!isLoading) {
      _isLoadingEventsSubj.add(false);
    } else {
      // If still loading after 2 seconds, notify the UI
      Future.delayed(const Duration(seconds: 2), () {
        if (isLoading) {
          _isLoadingEventsSubj.add(true);
        }
      });
    }
  }

  PublishSubject<List<ChatItem>> _itemSubj = PublishSubject<List<ChatItem>>();
  Stream<List<ChatItem>> get items => _itemSubj.stream;

  Future<void> startLoadingEvents() async {
    // Do a first load only from memory/disk
    // A remote request can be longggg, especially during
    // startup when the first sync happens at the same time
    await loadEvents(false);

    syncBloc.stream.listen((success) async => await loadEvents(true));
  }

  Future<void> requestMoreEvents() async {
    if (!_isLoading) {
      isLoading = true;
      _eventCount += 50;
      await loadEvents(true);
      isLoading = false;
    }
  }

  Future<void> loadEvents(bool allowRemote) async {
    final chatItems = List<ChatItem>();

    // Get all rooms and push them as a single list

    // Remember: 'previous' is actually next in time
    RoomEvent previousEvent;
    await for(RoomEvent event in room.timeline.upTo(_eventCount, allowRemote: allowRemote)) {

      if (event is RedactionEvent) {
        continue;
      }

      // Insert DateHeader if there's a day difference
      if (previousEvent != null && event != null
        && previousEvent.time.day != event.time.day) {
        chatItems.add(DateItem(previousEvent.time));
      }

      chatItems.add(ChatEvent(event));

      previousEvent = event;
    }

    _itemSubj.add(List.of(chatItems));
  }

  Future<void> sendMessage(String text) async {
    // TODO: Check if text is just whitespace
    if (text.isNotEmpty) {
      // Refresh the list every time the sent state changes.
      await for (var sentState in room.send(TextMessage(body: text))) {
        await loadEvents(false);
      }
    }
  }
}
