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
import 'package:pattle/src/ui/util/user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pattle/src/di.dart' as di;
import 'package:flutter_html/flutter_html.dart';

import 'bubble.dart';
import 'message_bubble.dart';

class TextBubble extends MessageBubble {

  static const _replyMargin = 8.0;
  static const _replyLeftPadding = 12.0;

  @override
  final TextMessageEvent event;

  final User me = di.getLocalUser();

  TextBubble({
    @required ChatEvent item,
    ChatItem previousItem,
    ChatItem nextItem,
    @required bool isMine,
    RoomEvent reply,
  }) :
    event = item.event,
    super(
      item: item,
      previousItem: previousItem,
      nextItem: nextItem,
      isMine: isMine,
      reply: reply
  );

  TextStyle _linkStyle(BuildContext context) {
    if (isMine) {
      return textStyle(context).copyWith(
        decoration: TextDecoration.underline
      );
    } else {
      return textStyle(context).copyWith(
        color: Theme.of(context).primaryColor,
        decoration: TextDecoration.underline
      );
    }
  }

  Widget _buildRepliedTo(BuildContext context) {
    final repliedId = event.content.inReplyToId;
    if (repliedId != null) {
      return FutureBuilder<Event>(
        future: Future.value(event.room.events[repliedId]),
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          final repliedTo = snapshot.data;
          if (repliedTo != null && repliedTo is TextMessageEvent) {
            return !isRepliedTo ? Padding(
              padding: EdgeInsets.only(
                top: !isMine ? 4 : 0,
                bottom: _replyMargin,
              ),
              // Only build the replied-to message if this itself
              // is not a replied-to message (to prevent very long
              // reply chains)
              child: Bubble.asReply(
                reply: event,
                replyTo: repliedTo,
                isMine: repliedTo.sender.isIdenticalTo(me)
              ),
            ) : Container();
          } else {
            return Container(height: 0, width: 0);
          }
        },
      );
    } else {
      return Container(height: 0, width: 0);
    }
  }

  @protected
  Widget buildContent(BuildContext context) {
    return Html(
      data: event.content.formattedBody ?? '',
      useRichText: true,
      defaultTextStyle: textStyle(context),
      fillWidth: false,
      linkStyle: _linkStyle(context),
      onLinkTap: (url) async {
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
    );
  }

  @protected
  Widget buildMine(BuildContext context) {
    final needsBorder = isRepliedTo && reply.sender.isIdenticalTo(me);

    return InkWell(
      onTap: () { },
      customBorder: border(),
      child: CustomPaint(
        painter: needsBorder
          ? ReplyBorderPainter(
            color: Colors.white
          )
          : null,
        child: Padding(
          padding: Bubble.padding.copyWith(
              left: needsBorder ? _replyLeftPadding : null
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _buildRepliedTo(context),
              buildContent(context),
              SizedBox(height: 4),
              buildBottomIfEnd(context)
            ],
          ),
        ),
      )
    );
  }

  @protected
  Widget buildTheirs(BuildContext context) {
    final needsBorder = isRepliedTo && !reply.sender.isIdenticalTo(me);
    return InkWell(
      onTap: () {},
      customBorder: border(),
      child: CustomPaint(
        painter: needsBorder
            ? ReplyBorderPainter(
          color: colorOf(event.sender),
        )
        : null,
        child: Padding(
          padding: Bubble.padding.copyWith(
              left: needsBorder ? _replyLeftPadding : null
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildSender(context),
              _buildRepliedTo(context),
              SizedBox(height: 4),
              buildContent(context),
              SizedBox(height: 4),
              buildTime(context)
            ],
          ),
        ),
      )
    );
  }
}

class ReplyBorderPainter extends CustomPainter {

  static const width = 4.0;

  final Color color;

  ReplyBorderPainter({@required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(0, 0),
          Offset(width, size.height)
        ),
        topLeft: Bubble.radiusForBorder,
        bottomLeft: Bubble.radiusForBorder
      ),
      Paint()..color = color
    );
  }

  @override
  bool shouldRepaint(ReplyBorderPainter oldDelegate)
    => color != oldDelegate.color;

}