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

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import '../../../../resources/intl/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../models/chat.dart';

class TypingContent extends StatelessWidget {
  final Chat chat;
  final TextStyle style;

  const TypingContent({
    Key key,
    @required this.chat,
    this.style,
  }) : super(key: key);

  List<TextSpan> _span(BuildContext context, Room room) {
    if (room.isDirect || room.typingUserIds.isEmpty) {
      return [TextSpan(text: context.intl.chat.typing)];
    }

    if (chat.typingMembers.length == 1) {
      return context.intl.chat.isTyping.toTextSpans(
        chat.typingMembers.first.name,
      );
    } else {
      return context.intl.chat.areTyping.toTextSpans(
        chat.typingMembers.length > 2, // If true, shows 'and more' message
        chat.typingMembers.first.name,
        chat.typingMembers[1].name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TextStyle(
          color: context.pattleTheme.data.primaryColorOnBackground,
        );

    return Text.rich(
      TextSpan(
        style: style.copyWith(
          fontWeight: FontWeight.bold,
        ),
        children: _span(context, chat.room),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
