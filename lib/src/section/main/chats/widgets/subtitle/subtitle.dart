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

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:provider/provider.dart';

import '../../../../../resources/theme.dart';
import '../../../../../models/chat.dart';

import '../../../../../matrix.dart';

import '../../../chat/widgets/bubble/state/content/creation.dart';
import '../../../chat/widgets/bubble/state/content/member_change.dart';
import '../../../chat/widgets/bubble/state/content/name_change.dart';
import '../../../chat/widgets/bubble/state/content/topic_change.dart';
import '../../../chat/widgets/bubble/state/content/avatar_change.dart';
import '../../../chat/widgets/bubble/state/content/upgrade.dart';

import '../typing_content.dart';
import 'content/image.dart';
import 'content/video.dart';
import 'content/redacted.dart';
import 'content/text.dart';
import 'content/unsupported.dart';

class Subtitle extends StatelessWidget {
  final Chat chat;
  final Widget child;

  const Subtitle({Key key, this.chat, this.child}) : super(key: key);

  static Widget withContent(Chat chat) {
    Widget content;

    if (chat.room.isSomeoneElseTyping) {
      content = TypingContent(chat: chat);
    } else {
      final event = chat.latestMessage?.event;
      if (event == null) {
        content = UnsupportedSubtitleContent();
      } else if (event is TextMessageEvent) {
        content = TextSubtitleContent();
      } else if (event is ImageMessageEvent) {
        content = ImageSubtitleContent();
      } else if (event is VideoMessageEvent) {
        content = VideoSubtitleContent();
      } else if (event is MemberChangeEvent) {
        content = MemberChangeContent(message: chat.latestMessage);
      } else if (event is RedactedEvent) {
        content = RedactedSubtitleContent();
      } else if (event is NameChangeContent) {
        content = NameChangeContent(message: chat.latestMessage);
      } else if (event is TopicChangeEvent) {
        content = TopicChangeContent(message: chat.latestMessage);
      } else if (event is RoomAvatarChangeEvent) {
        content = AvatarChangeContent(chat: chat, message: chat.latestMessage);
      } else if (event is RoomUpgradeEvent) {
        content = UpgradeContent(message: chat.latestMessage);
      } else if (event is RoomCreationEvent) {
        content = CreationContent(message: chat.latestMessage);
      } else {
        content = UnsupportedSubtitleContent();
      }
    }

    return Subtitle(
      chat: chat,
      child: content,
    );
  }

  static Subtitle of(BuildContext context) =>
      Provider.of<Subtitle>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      textAlign: TextAlign.start,
      style: Theme.of(context).textTheme.bodyText2.copyWith(
            color: Theme.of(context).textTheme.caption.color,
          ),
      child: Provider<Subtitle>.value(
        value: this,
        // Builder is necessary to get context with
        // correct DefaultTextStyle.
        child: Builder(
          builder: (context) {
            return Row(
              children: <Widget>[
                Expanded(
                  child: IconTheme(
                    data: IconThemeData(
                      color: DefaultTextStyle.of(context).style.color,
                      size: 20,
                    ),
                    child: child,
                  ),
                ),
                if (_InviteIcon.necessary(context)) _InviteIcon(),
                if (_NotificationCount.necessary(context)) _NotificationCount(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Sender extends StatelessWidget {
  const Sender({Key key}) : super(key: key);

  static bool necessary(BuildContext context) {
    final chat = Subtitle.of(context).chat;
    final message = chat.latestMessage;

    return message.event.senderId != Matrix.of(context).user.id &&
        !chat.isDirect;
  }

  @override
  Widget build(BuildContext context) {
    final message = Subtitle.of(context).chat.latestMessage;

    return Text(
      '${message.sender.name}: ',
      maxLines: 1,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}

class _InviteIcon extends StatelessWidget {
  static bool necessary(BuildContext context) {
    return Subtitle.of(context).chat.room.me.isInvited;
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.mail,
      color: Theme.of(context).primaryColor,
      size: 20,
    );
  }
}

class _NotificationCount extends StatelessWidget {
  static bool necessary(BuildContext context) {
    return Subtitle.of(context).chat.room.totalUnreadNotificationCount > 0;
  }

  @override
  Widget build(BuildContext context) {
    final room = Subtitle.of(context).chat.room;

    return SizedBox(
      height: 21,
      width: 21,
      child: ClipOval(
        child: Container(
          color: room.highlightedUnreadNotificationCount > 0
              ? context.pattleTheme.data.primaryColor
              : Colors.grey,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Center(
              child: Text(
                room.totalUnreadNotificationCount.toString(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
