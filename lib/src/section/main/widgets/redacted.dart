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
import 'package:pattle/src/resources/localizations.dart';

import '../../../matrix.dart';
import '../../../util//user.dart';

class Redacted extends StatelessWidget {
  final RedactedEvent event;

  final Color color;
  final double iconSize;

  const Redacted({
    @required this.event,
    this.iconSize,
    this.color,
  }) : super();

  @override
  Widget build(BuildContext context) {
    List<TextSpan> text;
    if (event.redaction.sender == Matrix.of(context).user) {
      text = [TextSpan(text: ' ${l(context).youDeletedThisMessage}')];
    } else {
      text = l(context).hasDeletedThisMessage(
        TextSpan(text: ' ${event.redaction.sender.displayName}'),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.delete,
          color: color,
          size: iconSize,
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: color,
              fontStyle: FontStyle.italic,
            ),
            children: text,
          ),
        )
      ],
    );
  }
}
