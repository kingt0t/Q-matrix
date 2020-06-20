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

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:video_player/video_player.dart' as flutter;

import '../../widgets/video_button.dart';

import '../../../../../util/url.dart';

class VideoPlayer extends StatefulWidget {
  /// If [autoPlay] is true, controls will be hidden immediately.
  final bool autoPlay;
  final VideoMessageEvent event;

  final VoidCallback onControlsShown;
  final VoidCallback onControlsHidden;

  const VideoPlayer({
    Key key,
    @required this.event,
    this.autoPlay = false,
    this.onControlsShown,
    this.onControlsHidden,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  flutter.VideoPlayerController _controller;

  bool _initialized = false;

  bool _isPlaying = false;

  double _aspectRatio;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Timer _hideControlsTimer;
  bool _controlsVisible;

  Timer _loadingBarTimer;
  bool _loadingBarVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controlsVisible = !widget.autoPlay;

    final url = widget.event.content.url?.toHttps(context);

    _loadingBarTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _loadingBarVisible = true;
      });
    });

    DefaultCacheManager().getFileFromCache(url).then((info) {
      if (info?.file == null) {
        _controller = flutter.VideoPlayerController.network(url);

        // Download the file for future use
        // TODO: Find way to cache downloaded video via .network controller
        DefaultCacheManager().downloadFile(url);
      } else {
        _controller = flutter.VideoPlayerController.file(info.file);
      }

      _controller.initialize().then(
        (_) {
          _loadingBarTimer?.cancel();

          // Set state to show the first frame if we're not playing the
          // video immediately, and to build the VideoPlayer widget
          setState(() {
            _initialized = true;
            _duration = _controller.value.duration;
            _loadingBarVisible = false;
          });
          if (widget.autoPlay) {
            _togglePlay();
          }

          _controller.addListener(() {
            if (_controller.value.position != _position ||
                _isPlaying != _controller.value.isPlaying) {
              setState(() {
                _position = _controller.value.position;
                _isPlaying = _controller.value.isPlaying;

                // Done playing, show controls again
                if (_position >= _duration) {
                  _controlsVisible = true;
                  widget?.onControlsShown?.call();
                }
              });
            }
          });
        },
      );
    });

    final info = widget.event.content.info;

    final width = info?.width ?? info?.thumbnail?.width;
    final height = info?.height ?? info?.thumbnail?.height;
    if (width != null && height != null) {
      _aspectRatio = width / height;
    }
  }

  void _togglePlay() {
    // Controller is not yet initialized, do nothing
    if (_controller == null) {
      return;
    }

    if (_isPlaying) {
      _controller.pause();
    } else {
      if (_position >= _duration) {
        _seekTo(0);
      }

      _controller.play();

      _hideControlsEventually();
    }
  }

  void _seekTo(double milliseconds) {
    final wasPlaying = _isPlaying;
    if (wasPlaying) {
      _controller.pause();
    }

    _controller.seekTo(Duration(milliseconds: milliseconds.round()));

    if (wasPlaying) {
      _controller.play();
    }
  }

  void _showControls() {
    setState(() {
      _controlsVisible = true;
      widget.onControlsShown?.call();
    });

    _hideControlsEventually();
  }

  void _hideControlsEventually() {
    _hideControlsTimer?.cancel();

    _hideControlsTimer = Timer(Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() {
          _controlsVisible = false;
          widget.onControlsHidden?.call();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayer = _initialized
        ? flutter.VideoPlayer(_controller)
        : CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl:
                widget.event.content.info.thumbnail?.url?.toHttps(context),
          );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (_aspectRatio != null)
          Center(
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: videoPlayer,
            ),
          )
        else
          videoPlayer,
        GestureDetector(
          onTap: _showControls,
        ),
        Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: !_loadingBarVisible
                ? _controlsVisible
                    ? !_isPlaying
                        ? PlayButton(onPressed: _togglePlay)
                        : PauseButton(onPressed: _togglePlay)
                    : Container()
                : CircularProgressIndicator(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            switchInCurve: Curves.decelerate,
            switchOutCurve: Curves.decelerate.flipped,
            child: _controlsVisible
                ? Container(
                    key: ValueKey(_controlsVisible),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0),
                        ],
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        _Time(_position),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: _duration.inMilliseconds.toDouble(),
                            value: _position.inMilliseconds.toDouble().clamp(
                                  0.0,
                                  _duration.inMilliseconds.toDouble(),
                                ),
                            onChanged: _seekTo,
                          ),
                        ),
                        _Time(_duration),
                      ],
                    ),
                  )
                : Container(key: ValueKey(_controlsVisible)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class _Time extends StatelessWidget {
  final Duration duration;

  const _Time(this.duration, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (duration.inSeconds - (Duration.secondsPerMinute * duration.inMinutes))
            .toString()
            .padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }
}
