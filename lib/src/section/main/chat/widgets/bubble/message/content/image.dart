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

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:provider/provider.dart';

import '../../../../image/page.dart';
import '../../message.dart';

import '../../../../util/image_provider.dart';

/// Creates an [ImageContent] widget for a [MessageBubble].
///
/// Must have a [MessageBubble] ancestor.
class ImageContent extends StatefulWidget {
  ImageContent({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageContentState();
}

class _ImageContentState extends State<ImageContent> {
  static const double _width = 256;
  static const double _minHeight = 72;
  static const double _maxHeight = 292;

  bool get _isFile => _fileUri != null;
  Uri _fileUri;

  double _height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bubble = MessageBubble.of(context);
    assert(bubble.message.event is ImageMessageEvent);

    final event = bubble.message.event as ImageMessageEvent;

    _height = (event.content.info?.height ??
            0 / (event.content.info?.width ?? 0 / _width))
        .clamp(_minHeight, _maxHeight)
        .toDouble();

    if (event.content.url.isScheme('file')) {
      _fileUri = event.content.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);
    final event = bubble.message.event as ImageMessageEvent;

    return OpenContainer(
      tappable: false,
      closedElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: bubble.borderRadius),
      closedBuilder: (_, void Function() action) {
        // Reprovide the MessageBubble
        return Provider<MessageBubble>.value(
          value: bubble,
          child: Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(borderRadius: bubble.borderRadius),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: bubble.borderRadius,
                    child: Image(
                      image: imageProvider(
                        context: context,
                        url: _isFile ? _fileUri : event.content.url,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (MessageInfo.necessary(context)) _MessageInfo(),
                if (Sender.necessary(context)) _Sender(),
                Positioned.fill(
                  child: Clickable(
                    extraMaterial: true,
                    onTap: () => action(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (_, void Function() action) {
        final bubble = MessageBubble.of(context);

        return ImagePage.withBloc(
          bubble.chat.room.id,
          bubble.message.event.id,
        );
      },
    );
  }
}

class _MessageInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    var alignment, borderRadius;
    if (bubble.message.isMine) {
      alignment = Alignment.bottomRight;
      borderRadius = bubble.borderRadius;
    } else {
      alignment = Alignment.bottomLeft;
      borderRadius = BorderRadius.all(bubble.borderRadius.bottomLeft);
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: bubble.contentPadding,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Color(0x64000000),
          ),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: Colors.white,
                  ),
              child: MessageInfo(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Sender extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: bubble.contentPadding,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: bubble.borderRadius,
            color: Color(0x64000000),
          ),
          child: Padding(
            padding: EdgeInsets.all(6),
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.white,
              ),
              child: Sender(personalizedColor: false),
            ),
          ),
        ),
      ),
    );
  }
}
