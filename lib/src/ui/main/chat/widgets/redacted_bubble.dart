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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/models/chat_item.dart';
import 'package:pattle/src/di.dart' as di;
import 'package:pattle/src/ui/main/widgets/redacted.dart';

import 'bubble.dart';
import 'message_bubble.dart';


class RedactedBubble extends MessageBubble {

  @override
  final RedactedEvent event;

  final LocalUser me = di.getLocalUser();

  RedactedBubble({
    @required ChatEvent item,
    ChatItem previousItem,
    ChatItem nextItem,
    @required bool isMine
  }) :
    event = item.event,
    super(
      item: item,
      previousItem: previousItem,
      nextItem: nextItem,
      isMine: isMine
  );

  @protected
  Widget buildContent(BuildContext context) =>
    Redacted(
      event: event,
      color: isMine ? Colors.grey[300] : Colors.grey[700],
      textStyle: textStyle(context),
    );

  @override
  Widget buildMine(BuildContext context) {
    return InkWell(
      onTap: () { },
      customBorder: border(),
      child: Padding(
        padding: Bubble.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            buildContent(context),
            SizedBox(height: 4),
            buildBottomIfEnd(context)
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTheirs(BuildContext context) {
    return InkWell(
      onTap: () {},
      customBorder: border(),
      child: Padding(
        padding: Bubble.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildSender(context),
            SizedBox(height: 4),
            buildContent(context),
            SizedBox(height: 4),
            buildTime(context)
          ],
        ),
        ),
      );
  }
}