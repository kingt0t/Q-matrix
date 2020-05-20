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
import 'package:meta/meta.dart';

import 'chat_member.dart';
import 'chat_message.dart';

import '../util/room.dart';

/// Chat overview used in the 'chats' page.
@immutable
class Chat {
  final Room room;

  // TODO: When members are able to being accessed syncly, use member names
  //       for groups
  final String name;

  final Uri avatarUrl;

  final ChatMessage latestMessage;
  final ChatMessage latestMessageForSorting;

  final bool isJustMe;

  final ChatMember directMember;

  final List<ChatMember> typingMembers;

  bool get isDirect => room.isDirect;
  bool get isChannel =>
      room.joinRule == JoinRule.public || room.joinRule == JoinRule.knock;

  bool get isInvite => room.myMembership == Membership.invited;

  Chat({
    @required this.room,
    this.latestMessage,
    this.latestMessageForSorting,
    this.isJustMe = false,
    this.directMember,
  })  : name = room.name ??
            (room.isDirect ? directMember.name : room.id.toString()),
        avatarUrl = room.avatarUrl ??
            (room.isDirect ? directMember.avatarUrl : room.avatarUrl),
        typingMembers = room.typingUserIds
            .map((id) => ChatMember.fromRoomAndUserId(room, id, isMe: false))
            .toList();

  @override
  bool operator ==(dynamic other) => other is Chat ? other.room == room : false;

  @override
  int get hashCode => room.hashCode;
}

extension RoomToChat on Room {
  Chat toChat({@required UserId myId}) {
    // We should always have at least 30 items in the timeline, so don't load
    final latestEvent = timeline.firstWhere(
      (event) => !ignoredEvents.contains(event.runtimeType),
      orElse: () => null,
    );

    var latestEventForSorting = timeline.firstWhere(
      (event) =>
          (event is! MemberChangeEvent ||
              (event is JoinEvent &&
                  event is! DisplayNameChangeEvent &&
                  event is! AvatarChangeEvent &&
                  event.subjectId == myId)) &&
          event is! RedactionEvent,
      orElse: () => null,
    );

    // If there is no non-MemberChangeEvent in the last
    // 10 messages, just settle for the most recent one (which ever
    // type it is).
    if (latestEventForSorting == null) {
      latestEventForSorting = latestEvent;
    }

    return Chat(
      room: this,
      isJustMe: summary.joinedMembersCount == 1,
      latestMessage: latestEvent != null
          ? ChatMessage(
              this,
              latestEvent,
              isMe: (id) => id == myId,
            )
          : null,
      latestMessageForSorting: latestEventForSorting != null
          ? ChatMessage(
              this,
              latestEventForSorting,
              isMe: (id) => id == myId,
            )
          : null,
      directMember: isDirect
          ? ChatMember.fromRoomAndUserId(
              this,
              directUserId,
              isMe: directUserId == myId,
            )
          : null,
    );
  }
}

extension Channels on Iterable<Chat> {
  Iterable<Chat> get channels => where((c) => c.isChannel);

  Iterable<Chat> get notChannels => where((c) => !c.isChannel);
}
