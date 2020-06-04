// Copyright (C) 2020  Wilko Manger
// Copyright (C) 2019  Mathieu Velten (FLA signed)
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

import '../../../../../../../resources/intl/localizations.dart';

import '../../../../../chats/widgets/chat_avatar.dart';

import '../../../../../../../models/chat.dart';
import '../../../../../../../models/chat_message.dart';

import '../state.dart';
import 'state_content.dart';

/// If [message] is `null`, will try to get the [message] from the
/// ancestor [StateBubble].
class AvatarChangeContent extends StatelessWidget {
  final Chat chat;
  final ChatMessage message;
  final bool withImage;

  const AvatarChangeContent({
    Key key,
    this.chat,
    this.message,
    this.withImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = StateContent.singleName(
      message: message,
      content: (withImage
              ? context.intl.chat.message.iconChangeTo
              : context.intl.chat.message.iconChange)
          .toTextSpans,
      person: (message) => message.sender.person,
      name: (message) => message.sender.name,
    );

    return !withImage
        ? content
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              content,
              SizedBox(
                width: DefaultTextStyle.of(context).style.fontSize * 0.3,
              ),
              ChatAvatar(
                chat: chat ?? StateBubble.of(context).chat,
                radius: DefaultTextStyle.of(context).style.fontSize * 0.8,
              ),
            ],
          );
  }
}
