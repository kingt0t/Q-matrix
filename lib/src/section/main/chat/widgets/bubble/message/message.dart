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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:provider/provider.dart';

import '../../../../../../models/chat.dart';
import '../../../../../../models/chat_message.dart';

import '../../../../../../resources/theme.dart';

import '../../../../widgets/message_state.dart';

import 'content/image.dart';
import 'content/redacted.dart';
import 'content/text.dart';

import '../../../../../../util/date_format.dart';
import '../../../../../../util/chat_member.dart';

class MessageBubble extends StatelessWidget {
  final Chat chat;

  final ChatMessage message;
  final ChatMessage previousMessage;
  final ChatMessage nextMessage;

  final bool isStartOfGroup;
  final bool isEndOfGroup;

  /// If this is not null, this bubble is rendered above another
  /// bubble, because it's replied to by [reply].
  final ChatMessage reply;

  bool get isRepliedTo => reply != null;

  final BorderRadius borderRadius;

  final Color color;

  final Widget child;

  final EdgeInsets contentPadding = EdgeInsets.all(8);

  final double replySlideUnderDistance = 16;

  static const _groupTimeLimit = Duration(minutes: 3);

  static const _oppositePadding = 48.0;

  static const _paddingBetween = 8.0;
  static const _paddingBetweenSameGroup = 2.0;

  MessageBubble._({
    @required this.chat,
    @required this.message,
    this.previousMessage,
    this.nextMessage,
    @required this.isStartOfGroup,
    @required this.isEndOfGroup,
    this.reply,
    @required this.borderRadius,
    @required this.child,
    this.color,
  }) : super(
          key: ValueKey(
            message.event.transactionId ?? message.event.id.toString(),
          ),
        );

  factory MessageBubble({
    @required Chat chat,
    @required ChatMessage message,
    ChatMessage previousMessage,
    ChatMessage nextMessage,
    ChatMessage reply,
    Color color,
    @required Widget child,
  }) {
    final isStartOfGroup = _isStartOfGroup(message, previousMessage, reply);
    final isEndOfGroup = _isEndofGroup(message, nextMessage, reply);

    return MessageBubble._(
      chat: chat,
      message: message,
      previousMessage: previousMessage,
      nextMessage: nextMessage,
      isStartOfGroup: isStartOfGroup,
      isEndOfGroup: isEndOfGroup,
      reply: reply,
      borderRadius: _borderRadius(message, isEndOfGroup, isStartOfGroup),
      color: color,
      child: child,
    );
  }

  /// Create a [MessageBubble] with the correct [child] for the given [message].
  factory MessageBubble.withContent({
    @required Chat chat,
    @required ChatMessage message,
    ChatMessage previousMessage,
    ChatMessage nextMessage,
    ChatMessage reply,
  }) {
    final event = message.event;

    Widget content =
        Container(); // TODO: Create default unsupported event content
    if (event is TextMessageEvent) {
      content = TextContent();
    } else if (event is ImageMessageEvent) {
      content = ImageContent(
          key: ValueKey(
        message.event.transactionId ?? message.event.id.toString(),
      ));
    } else if (event is RedactedEvent) {
      content = RedactedContent();
    }

    return MessageBubble(
      chat: chat,
      message: message,
      previousMessage: previousMessage,
      nextMessage: nextMessage,
      reply: reply,
      child: content,
    );
  }

  static bool _isStartOfGroup(
    ChatMessage message,
    ChatMessage previousMessage,
    ChatMessage reply,
  ) {
    if (reply != null) {
      return false;
    }

    final event = message.event;
    final previousEvent = previousMessage?.event;

    if (previousEvent is StateEvent) {
      return true;
    }

    final previousHasSameSender = previousEvent != null &&
        previousMessage.sender.name == previousMessage.sender.name &&
        previousEvent.senderId == event.senderId;

    if (!previousHasSameSender) {
      return true;
    }

    // Difference between time is greater than 3 min
    final limit = event.time.subtract(_groupTimeLimit).millisecondsSinceEpoch;

    if (previousEvent.time.millisecondsSinceEpoch <= limit) {
      return true;
    }

    return false;
  }

  static bool _isEndofGroup(
    ChatMessage message,
    ChatMessage nextMessage,
    ChatMessage reply,
  ) {
    if (reply != null) {
      return false;
    }

    final event = message.event;
    final nextEvent = nextMessage?.event;

    if (nextEvent is StateEvent) {
      return true;
    }

    final nextHasSameSender = nextEvent != null &&
        nextMessage.sender.name == nextMessage.sender.name &&
        nextEvent.senderId == event.senderId;

    if (!nextHasSameSender) {
      return true;
    }

    // Difference between time is greater than 3 min
    final limit = event.time.add(_groupTimeLimit).millisecondsSinceEpoch;

    if (nextEvent.time.millisecondsSinceEpoch >= limit) {
      return true;
    }

    return false;
  }

  static BorderRadius _borderRadius(
    ChatMessage message,
    bool isEndOfGroup,
    bool isStartOfGroup,
  ) {
    const radius = Radius.circular(8);
    var borderRadius = BorderRadius.all(radius);

    if (message.isMine) {
      if (isEndOfGroup) {
        borderRadius = BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
        );
      }
    } else {
      if (isStartOfGroup) {
        borderRadius = BorderRadius.only(
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
    }

    return borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    var color = this.color;

    if (color == null) {
      if (message.isMine) {
        if (!isRepliedTo) {
          color = context.pattleTheme.data.chat.myMessage.backgroundColor;
        } else {
          color =
              context.pattleTheme.data.chat.myMessage.repliedTo.backgroundColor;
        }
      } else {
        if (!isRepliedTo) {
          color = context.pattleTheme.data.chat.theirMessage.backgroundColor;
        } else {
          color = context
              .pattleTheme.data.chat.theirMessage.repliedTo.backgroundColor;
        }
      }
    }

    final border = RoundedRectangleBorder(borderRadius: borderRadius);

    Widget widget = Material(
      color: color,
      elevation: 1,
      shape: border,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText2.apply(
              fontSizeFactor: 1.1,
              color: message.isMine ? Colors.white : null,
            ),
        child: Provider<MessageBubble>.value(
          value: this,
          child: child,
        ),
      ),
    );

    if (message.inReplyTo != null) {
      widget = _ReplyLayout(
        replySlideUnderDistance: replySlideUnderDistance,
        reply: MessageBubble.withContent(
          chat: chat,
          message: message.inReplyTo,
          reply: message,
        ),
        messageIsMine: message.isMine,
        message: widget,
      );
    }

    if (!isRepliedTo) {
      return Align(
        alignment:
            message.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: reply == null
              ? EdgeInsets.only(
                  left: message.isMine ? _oppositePadding : 0,
                  right: !message.isMine ? _oppositePadding : 0,
                  top: previousMessage == null ? _paddingBetween : 0,
                  bottom:
                      isEndOfGroup ? _paddingBetween : _paddingBetweenSameGroup,
                )
              : EdgeInsets.zero,
          child: widget,
        ),
      );
    } else {
      return widget;
    }
  }

  static MessageBubble of(BuildContext context) =>
      Provider.of<MessageBubble>(context, listen: false);
}

class _ReplyLayout extends MultiChildRenderObjectWidget {
  final Widget reply;
  final Widget message;

  final bool messageIsMine;
  final double replySlideUnderDistance;

  _ReplyLayout({
    @required this.reply,
    @required this.message,
    @required this.messageIsMine,
    @required this.replySlideUnderDistance,
  }) : super(
          children: [
            reply,
            message,
          ],
        );

  @override
  _ReplyLayoutRenderBox createRenderObject(BuildContext context) {
    return _ReplyLayoutRenderBox()
      ..messageIsMine = messageIsMine
      ..replySlideUnderDistance = replySlideUnderDistance;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _ReplyLayoutRenderBox renderObject,
  ) {
    renderObject.replySlideUnderDistance = replySlideUnderDistance;
  }
}

class _ReplyLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ReplyLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ReplyLayoutParentData> {
  bool messageIsMine;
  double replySlideUnderDistance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ReplyLayoutParentData) {
      child.parentData = _ReplyLayoutParentData();
    }
  }

  RenderBox get _reply {
    return firstChild;
  }

  RenderBox get _message {
    return (firstChild.parentData as _ReplyLayoutParentData).nextSibling;
  }

  @override
  void performLayout() {
    assert(childCount == 2);

    final reply = _reply;
    final message = _message;

    reply.layout(
      constraints,
      parentUsesSize: true,
    );

    message.layout(
      constraints,
      parentUsesSize: true,
    );

    final height =
        message.size.height + reply.size.height - replySlideUnderDistance;

    final width = max(
      reply.size.width,
      message.size.width,
    );

    message.layout(
      BoxConstraints.tightFor(width: width),
      parentUsesSize: true,
    );

    size = constraints.constrain(Size(width, height));

    final messageParentData = message.parentData as _ReplyLayoutParentData;
    messageParentData.offset = Offset(
      0,
      reply.size.height - replySlideUnderDistance,
    );

    if (messageIsMine) {
      final replyParentData = reply.parentData as _ReplyLayoutParentData;
      replyParentData.offset = Offset(message.size.width - reply.size.width, 0);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _ReplyLayoutParentData extends ContainerBoxParentData<RenderBox> {}

/// Helper widget to make a [MessageBubble] clickable with a ripple. Defaults
/// to showing a context menu on tap, and being selected on long press.
///
/// Must have a [MessageBubble] ancestor.
class Clickable extends StatelessWidget {
  /// In some cases an extra [Material] widget is necessary to render the
  /// ripple correctly.
  final bool extraMaterial;
  final VoidCallback onTap;
  final Widget child;

  const Clickable({
    Key key,
    this.extraMaterial = false,
    this.onTap,
    this.child,
  }) : super(key: key);

  void _showContextMenu() {}

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    final inkWell = InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: bubble.borderRadius),
      onTap: onTap ?? _showContextMenu,
      child: child,
    );

    if (!extraMaterial) {
      return inkWell;
    } else {
      return Material(
        color: Colors.transparent,
        child: inkWell,
      );
    }
  }
}

/// Conditionally shows sent state and message time.
///
/// Must have a [MessageBubble] ancestor.
class MessageInfo extends StatelessWidget {
  const MessageInfo({Key key}) : super(key: key);

  static bool necessary(BuildContext context) {
    final bubble = MessageBubble.of(context);

    return bubble.isEndOfGroup || MessageState.necessaryInBubble(context);
  }

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (MessageState.necessaryInBubble(context)) ...[
          MessageState(
            message: bubble.message,
            color: context.pattleTheme.data.chat.myMessage.contentColor,
            size: 14,
          ),
          SizedBox(width: 4),
        ],
        if (bubble.isEndOfGroup)
          Text(
            formatAsTime(bubble.message.event.time),
            style: DefaultTextStyle.of(context).style.apply(
                  fontSizeFactor: 0.8,
                ),
          ),
      ],
    );
  }
}

/// Conditionally shows sender.
///
/// Must have a [MessageBubble] ancestor.
class Sender extends StatelessWidget {
  /// If true, the color of the sender will be based on their Matrix ID.
  final bool personalizedColor;

  const Sender({
    Key key,
    this.personalizedColor = true,
  }) : super(key: key);

  static bool necessary(BuildContext context) {
    final bubble = MessageBubble.of(context);

    return !bubble.message.isMine &&
        !bubble.chat.isDirect &&
        (bubble.isStartOfGroup || bubble.reply != null);
  }

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    var color = personalizedColor ? bubble.message.sender.color(context) : null;

    return Text(
      bubble.message.sender.name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: bubble.isRepliedTo ? color?.withOpacity(0.70) : color,
      ),
    );
  }
}
