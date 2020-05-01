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

import 'package:meta/meta.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'chat_member.dart';

@immutable
class ChatMessage {
  final RoomEvent event;
  final ChatMember sender;

  final ChatMessage inReplyTo;
  bool get isReply => inReplyTo != null;

  bool get isMine => sender.isYou;

  final bool read;

  /// True if the message was loaded because of scrolling up. Can be null if
  /// not relevant.
  final bool historical;

  /// Message that redacted this message, if any.
  final ChatMessage redaction;

  /// Subject of a member change state change, if any.
  final ChatMember subject;

  ChatMessage._(
    this.event, {
    @required this.sender,
    this.inReplyTo,
    this.redaction,
    this.subject,
    @required this.read,
    this.historical,
  });
  @override
  bool operator ==(dynamic other) {
    if (other is ChatMessage) {
      return event == other.event &&
          inReplyTo == other.inReplyTo &&
          isMine == other.isMine;
    } else {
      return false;
    }
  }

  factory ChatMessage(
    Room room,
    RoomEvent event, {
    ChatMessage inReplyTo,
    @required bool Function(UserId) isMe,
    bool historical,
  }) {
    ChatMessage redactionMessage;
    ChatMember subject;

    bool isRead(RoomEvent e) {
      return room.readReceipts.where((r) => !isMe(r.userId)).any(
            (r) =>
                r.eventId == e.id ||
                (room.timeline[r.eventId]?.time?.isAfter(e.time) ?? false),
          );
    }

    if (event is RedactedEvent) {
      redactionMessage = ChatMessage._(
        event.redaction,
        sender: ChatMember.fromRoomAndUserId(
          room,
          event.redaction.senderId,
          isMe: isMe(event.redaction.senderId),
        ),
        read: isRead(event.redaction),
      );
    } else if (event is MemberChangeEvent) {
      subject = ChatMember.fromRoomAndUserId(
        room,
        event.subjectId,
        isMe: isMe(event.subjectId),
      );
    }

    return ChatMessage._(
      event,
      sender: ChatMember.fromRoomAndUserId(
        room,
        event.senderId,
        isMe: isMe(event.senderId),
      ),
      inReplyTo: inReplyTo,
      redaction: redactionMessage,
      subject: subject,
      read: isRead(event),
      historical: historical,
    );
  }

  @override
  int get hashCode =>
      hashCode + event.hashCode + inReplyTo.hashCode + isMine.hashCode;
}
