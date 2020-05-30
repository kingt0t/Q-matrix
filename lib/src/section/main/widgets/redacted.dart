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

import '../../../resources/intl/localizations.dart';
import '../../../models/chat_message.dart';

class Redacted extends StatelessWidget {
  final ChatMessage redaction;

  final Color color;
  final double iconSize;

  const Redacted({
    @required this.redaction,
    this.iconSize,
    this.color,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.delete,
          color: color,
          size: iconSize,
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: color,
                fontStyle: FontStyle.italic,
              ),
              children: context.intl.chat.message.deletion.toTextSpans(
                redaction.sender.person,
                redaction.sender.name,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
