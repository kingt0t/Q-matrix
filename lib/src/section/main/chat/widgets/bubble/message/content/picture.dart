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

import '../../../video_button.dart';
import '../../../../media/page.dart';
import '../../message.dart';

import '../../../../util/image_provider.dart';

/// Creates an [PictureContent] widget for a [MessageBubble].
///
/// Can be either for an `ImageMessageEvent` or a thumbnail for a
/// `VideoMessageEvent`.
///
/// Must have a [MessageBubble] ancestor.
class PictureContent extends StatefulWidget {
  PictureContent({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PictureContentState();
}

class _PictureContentState extends State<PictureContent> {
  static const double _width = 256;
  static const double _minHeight = 72;
  static const double _maxHeight = 292;

  bool _isVideo;

  Uri _uri;

  double _height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bubble = MessageBubble.of(context);
    final event = bubble.message.event;

    var height = 0, width = 0;
    if (event is ImageMessageEvent) {
      height = event.content.info?.height;
      width = event.content.info?.width;

      _uri = event.content.url;
      _isVideo = false;
    } else if (event is VideoMessageEvent) {
      height = event.content.info?.thumbnail?.height ?? 0;
      width = event.content.info?.thumbnail?.width ?? 0;

      _uri = event.content.info?.thumbnail?.url;
      _isVideo = true;
    }

    _height =
        (height / (width / _width)).clamp(_minHeight, _maxHeight).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    final content = OpenContainer(
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
                    borderRadius: bubble.isRepliedTo
                        ? BorderRadius.all(bubble.borderRadius.bottomLeft)
                        : bubble.borderRadius,
                    child: Image(
                      image: imageProvider(
                        context: context,
                        url: _uri,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (MessageInfo.necessary(context)) _MessageInfo(),
                if (Sender.necessary(context)) _Sender(),
                if (_isVideo)
                  Center(
                    child: PlayIcon(),
                  ),
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

        return MediaPage.withBloc(
          bubble.chat.room.id,
          bubble.message.event.id,
        );
      },
    );

    if (bubble.dense) {
      return SizedBox(
        height: 96,
        width: 96,
        child: content,
      );
    } else {
      return content;
    }
  }
}

class _MessageInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bubble = MessageBubble.of(context);

    BorderRadius borderRadius;
    if (bubble.message.isMine) {
      borderRadius = bubble.borderRadius;
    } else {
      borderRadius = BorderRadius.all(bubble.borderRadius.bottomRight);
    }

    return Align(
      alignment: Alignment.bottomRight,
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
