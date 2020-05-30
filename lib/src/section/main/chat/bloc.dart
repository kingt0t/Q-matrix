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
import '../../../models/chat_message.dart';

import '../../../matrix.dart';
import '../../../util/room.dart';

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
      print('${update.type}');
      add(
        RefreshChat(
          chat: _chat,
          delta: update.delta,
          isBecauseOfTimelineRequest: update.type == RequestType.loadRoomEvents,
        ),
      );
    });
  }

  MyUser get me => _matrix.user;

  @override
  ChatState get initialState => _loadMessages(
        chat: _chat,
        delta: _room.delta(),
        becauseOfTimelineLoad: false,
      );

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is LoadMoreFromTimeline) {
      _room.timeline.load(count: _pageSize);
      return;
    }

    if (event is RefreshChat) {
      yield _loadMessages(
        chat: event.chat,
        delta: event.delta,
        becauseOfTimelineLoad: event.isBecauseOfTimelineRequest,
      );
    }

    if (event is MarkAsRead) {
      _markAllAsRead();
    }
  }

  ChatState _loadMessages({
    @required Chat chat,
    @required Room delta,
    @required bool becauseOfTimelineLoad,
  }) {
    final room = chat.room;
    final messages = <ChatMessage>[];

    RoomEvent event;
    for (event in room.timeline) {
      var shouldIgnore = false;
      // In direct chats, don't show the invite event between this user
      // and the direct user.
      //
      // Also in direct chats, don't show the join events between this user
      // and the direct user.
      if (room.isDirect) {
        if (event is InviteEvent) {
          final iInvitedYou =
              event.senderId == me && event.subjectId == room.directUserId;

          final youInvitedMe =
              event.senderId == room.directUserId && event.subjectId == me.id;

          shouldIgnore = iInvitedYou || youInvitedMe;
        } else if (event is JoinEvent) {
          final subject = event.subjectId;
          shouldIgnore = subject == me || subject == room.directUserId;
        }
      }

      shouldIgnore |= event is JoinEvent &&
          event is! DisplayNameChangeEvent &&
          room.creatorId == event.subjectId;

      // Don't show creation events in rooms that are replacements
      shouldIgnore |= event is RoomCreationEvent && room.isReplacement;

      if (room.ignoredEvents.contains(event.runtimeType) || shouldIgnore) {
        continue;
      }

      ChatMessage inReplyTo;
      if (event is MessageEvent && event.content?.inReplyToId != null) {
        // TODO: Might not be loaded?
        final inReplyToEvent = room.timeline[event.content.inReplyToId];

        if (inReplyToEvent != null) {
          inReplyTo = ChatMessage(
            room,
            inReplyToEvent,
            isMe: (id) => id == _matrix.user.id,
          );
        }
      }

      messages.add(
        ChatMessage(
          room,
          event,
          inReplyTo: inReplyTo,
          isMe: (id) => id == _matrix.user.id,
        ),
      );
    }

    var endReached = false;
    if (event is RoomCreationEvent) {
      endReached = true;
    }

    // Get messages new in update
    final newMessages = delta.timeline != null
        ? messages
            .where(
              (msg) => delta.timeline.any((event) => event.id == msg.event.id),
            )
            .toList()
        : <ChatMessage>[];

    return ChatState(
      chat: chat,
      messages: messages,
      newMessages: newMessages,
      endReached: endReached,
      wasTimelineLoad: becauseOfTimelineLoad,
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
