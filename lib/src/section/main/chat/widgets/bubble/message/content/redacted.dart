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

import '../../../../../../../models/chat_message.dart';
import '../../../../../widgets/redacted.dart';

import '../../../../../../../resources/theme.dart';

import '../../message.dart';

/// Redacted content for a [MessageBubble].
///
/// Must have a [MessageBubble] as ancestor.
class RedactedContent extends StatelessWidget {
  final ChatMessage message;

  const RedactedContent({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    return Clickable(
      child: Padding(
        padding: bubble.contentPadding,
        child: Column(
          crossAxisAlignment: bubble.message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            if (Sender.necessary(context)) Sender(),
            Redacted(
              redaction: bubble.message.redaction,
              color: bubble.message.isMine
                  ? context.pattleTheme.data.chat.myRedactedContentColor
                  : context.pattleTheme.data.chat.theirRedactedContentColor,
            ),
            if (MessageInfo.necessary(context))
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: MessageInfo(),
              ),
          ],
        ),
      ),
    );
  }
}
