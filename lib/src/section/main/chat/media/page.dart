// Copyright (C) 2020  Wilko Manger
// Copyright (C) 2019  Nathan van Beelen (CLA signed)
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:photo_view/photo_view.dart';

import '../../../../models/chat_message.dart';

import '../../../../matrix.dart';

import 'widgets/video_player.dart';

import '../../../../util/date_format.dart';
import '../util/image_provider.dart';

import 'bloc.dart';

class MediaPage extends StatefulWidget {
  final EventId eventId;

  MediaPage._(this.eventId);

  static Widget withBloc(RoomId roomId, EventId eventId) {
    return BlocProvider<MediaBloc>(
      create: (c) => MediaBloc(Matrix.of(c), roomId),
      child: MediaPage._(eventId),
    );
  }

  @override
  State<StatefulWidget> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  PageController _controller;

  ChatMessage _initial;
  ChatMessage _current;

  bool _hasSwitchedToOther = false;
  bool _appBarVisible = true;

  void _showAppBar() {
    setState(() {
      _appBarVisible = true;
    });
  }

  void _hideAppBar() {
    setState(() {
      _appBarVisible = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final messages = BlocProvider.of<MediaBloc>(context).state.messages;

    _initial = messages.firstWhere((msg) => msg.event.id == widget.eventId);
    _current = _initial;

    // If the initial event is a video, hide the app bar because the video
    // will auto play
    _appBarVisible = _initial.event is! VideoMessageEvent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _HideableAppBar(
        visible: _appBarVisible,
        child: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_current.sender.name),
              SizedBox(height: 2),
              Text(
                '${formatAsDate(context, _current.event.time)},'
                ' ${formatAsTime(_current.event.time)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Color(0x64000000),
        ),
      ),
      body: BlocBuilder<MediaBloc, MediaState>(builder: (context, state) {
        final messages = state.messages;

        _controller ??= PageController(
          initialPage: state.messages.indexOf(_current),
        );

        return PageView.builder(
          controller: _controller,
          itemCount: messages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final event = messages[index].event;

            if (event is ImageMessageEvent) {
              return PhotoView(
                imageProvider: imageProvider(
                  context: context,
                  url: event.content.url,
                ),
                minScale: PhotoViewComputedScale.contained,
              );
            } else if (event is VideoMessageEvent) {
              return VideoPlayer(
                event: event,
                autoPlay: event.equals(_initial.event) &&
                    !_hasSwitchedToOther &&
                    _current.event.equals(_initial.event),
                onControlsShown: _showAppBar,
                onControlsHidden: _hideAppBar,
              );
            } else {
              return Container();
            }
          },
          onPageChanged: (index) {
            setState(() {
              _current = messages[index];
              _appBarVisible = true;
              _hasSwitchedToOther = true;
            });
          },
        );
      }),
    );
  }
}

class _HideableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool visible;
  final Widget child;

  const _HideableAppBar({
    Key key,
    @required this.child,
    this.visible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      switchInCurve: Curves.decelerate,
      switchOutCurve: Curves.decelerate.flipped,
      child: visible ? child : Container(),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, kToolbarHeight);
}
