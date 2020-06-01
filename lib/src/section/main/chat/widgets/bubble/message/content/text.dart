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
import 'package:flutter/rendering.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../../../resources/theme.dart';

import '../../message.dart';

/// Content for a [MessageBubble] with a [TextMessageEvent].
///
/// Must have a [MessageBubble] ancestor.
class TextContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    return Clickable(
      child: Padding(
        padding: EdgeInsets.all(8).copyWith(
          bottom:
              bubble.reply != null ? bubble.replySlideUnderDistance + 8 : null,
        ),
        child: _ContentLayout(
          sender: Sender.necessary(context)
              ? Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Sender(),
                )
              : null,
          content: _Content(),
          info: MessageInfo.necessary(context)
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                  ),
                  child: MessageInfo(),
                )
              : null,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);
    assert(bubble.message.event is TextMessageEvent);
    final event = bubble.message.event as TextMessageEvent;

    Widget widget = Html(
      data: event.content.formattedBody ?? '',
      useRichText: true,
      shrinkToFit: true,
      crossAxisAlignment: CrossAxisAlignment.start,
      defaultTextStyle: TextStyle(
        color: bubble.message.isMine
            ? bubble.isRepliedTo
                ? context.pattleTheme.data.chat.myMessage.repliedTo.contentColor
                : context.pattleTheme.data.chat.myMessage.contentColor
            : bubble.isRepliedTo
                ? context
                    .pattleTheme.data.chat.theirMessage.repliedTo.contentColor
                : context.pattleTheme.data.chat.theirMessage.contentColor,
      ),
      linkStyle: TextStyle(
        decoration: TextDecoration.underline,
        color:
            !bubble.message.isMine ? context.pattleTheme.data.linkColor : null,
      ),
      renderNewlines: true,
      onLinkTap: (url) async {
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
    );

    if (event is EmoteMessageEvent) {
      widget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (Sender.necessary(context)) Sender(),
          Flexible(
            child: widget,
          )
        ],
      );
    }

    return widget;
  }
}

class _ContentLayout extends MultiChildRenderObjectWidget {
  final Widget sender;
  final Widget content;
  final Widget info;

  _ContentLayout({
    this.sender,
    @required this.content,
    this.info,
  }) : super(
          children: [
            if (sender != null)
              _ContentLayoutParentDataWidget(
                slot: _Slot.sender,
                child: sender,
              ),
            _ContentLayoutParentDataWidget(
              slot: _Slot.content,
              child: content,
            ),
            if (info != null)
              _ContentLayoutParentDataWidget(
                slot: _Slot.info,
                child: info,
              ),
          ],
        );

  @override
  _ContentLayoutRenderBox createRenderObject(BuildContext context) {
    return _ContentLayoutRenderBox();
  }
}

class _ContentLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ContentLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ContentLayoutParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _ContentLayoutParentData) {
      child.parentData = _ContentLayoutParentData();
    }
  }

  RenderBox get _sender {
    return getChildrenAsList().firstWhere(
      (r) => (r.parentData as _ContentLayoutParentData).slot == _Slot.sender,
      orElse: () => null,
    );
  }

  RenderBox get _content {
    return getChildrenAsList().firstWhere(
      (r) => (r.parentData as _ContentLayoutParentData).slot == _Slot.content,
      orElse: () => null,
    );
  }

  RenderBox get _info {
    return getChildrenAsList().firstWhere(
      (r) => (r.parentData as _ContentLayoutParentData).slot == _Slot.info,
      orElse: () => null,
    );
  }

  @override
  void performLayout() {
    final sender = _sender;
    final content = _content;
    final info = _info;

    var infoYOffset = 0.0;
    var width = 0.0, height = 0.0;

    if (sender != null) {
      sender.layout(constraints, parentUsesSize: true);

      height = constraints.constrainHeight(height + sender.size.height);

      (content.parentData as _ContentLayoutParentData).offset =
          Offset(0, height);
      infoYOffset = height;
    }

    content.layout(
      constraints,
      parentUsesSize: true,
    );

    width = constraints.constrainWidth(width + content.size.width);
    height = constraints.constrainHeight(height + content.size.height);

    if (info != null) {
      final minWidth =
          info.computeMinIntrinsicWidth(constraints.smallest.height);

      info.layout(
        BoxConstraints.tightFor(width: minWidth),
        parentUsesSize: true,
      );

      final contentParagraph = _getRenderParagraph(content);

      final lastLineBox = contentParagraph
          .getBoxesForSelection(
            TextSelection(
              baseOffset: 0,
              extentOffset: _getContentTextLength(contentParagraph),
            ),
          )
          .lastWhere(
            (_) => true,
            orElse: () => null,
          );

      if (lastLineBox != null) {
        final fitsLastLine =
            constraints.maxWidth - lastLineBox.right > info.size.width;

        if (constraints.maxWidth == double.infinity ||
            width.floor() != constraints.maxWidth.floor()) {
          width = constraints.constrainWidth(width + info.size.width);
        }

        final infoParentData = info.parentData as _ContentLayoutParentData;
        infoParentData.offset = Offset(
          width - info.size.width,
          infoYOffset +
              content.size.height -
              info.size.height +
              (!fitsLastLine ? info.size.height : 0),
        );

        if (!fitsLastLine) {
          height = constraints.constrainHeight(height + info.size.height);
        }
      }
    }

    if (sender != null && width < sender.size.width) {
      width = constraints.constrainWidth(sender.size.width);
    }

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  RenderParagraph _getRenderParagraph(RenderObject renderObject) {
    if (renderObject is RenderParagraph) {
      return renderObject;
    } else {
      RenderObject child;
      renderObject.visitChildren((c) {
        child = _getRenderParagraph(c);
      });

      return child;
    }
  }

  int _getContentTextLength(RenderParagraph renderParagraph) {
    final span = renderParagraph.text as TextSpan;

    if (span.children == null) {
      return 0;
    }

    var length = 0;
    for (final childSpan in span?.children) {
      if (childSpan is TextSpan) {
        length += childSpan.text?.length ?? 0;
      }
    }

    return length;
  }
}

class _ContentLayoutParentData extends ContainerBoxParentData<RenderBox> {
  _Slot slot;

  _ContentLayoutParentData();
}

enum _Slot {
  sender,
  content,
  info,
}

class _ContentLayoutParentDataWidget
    extends ParentDataWidget<_ContentLayoutParentData> {
  final _Slot slot;

  _ContentLayoutParentDataWidget({@required this.slot, @required Widget child})
      : super(child: child);

  @override
  void applyParentData(RenderObject renderObject) {
    final _ContentLayoutParentData parentData = renderObject.parentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _ContentLayoutParentData;
}
