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

import '../../../../widgets/message_state.dart';

import '../../../../../../util/reply.dart';

import '../subtitle.dart';

class TextSubtitleContent extends StatelessWidget {
  TextSubtitleContent({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = Subtitle.of(context).chat.latestMessage;
    final event = message.event as TextMessageEvent;
    final isReply = event.content.inReplyToId != null;

    var text = event.content.body;

    if (isReply) {
      // Strip replied-to content
      text = stripReply(text);
    }

    return Row(
      children: <Widget>[
        if (MessageState.necessary(message)) ...[
          MessageState(
            message: message,
          ),
          SizedBox(width: 4),
        ],
        if (Sender.necessary(context)) Sender(),
        if (isReply) Icon(Icons.reply),
        if (event is EmoteMessageEvent) Sender(),
        Expanded(
          child: Text(
            text ?? 'null',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
