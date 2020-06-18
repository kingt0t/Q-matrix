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

class VideoButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const VideoButton({
    Key key,
    @required this.onPressed,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: VideoIcon._size + (VideoIcon._padding * 2),
      icon: icon,
    );
  }
}

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoButton(
      onPressed: onPressed,
      icon: PlayIcon(),
    );
  }
}

class PauseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PauseButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoButton(
      onPressed: onPressed,
      icon: PauseIcon(),
    );
  }
}

class VideoIcon extends StatelessWidget {
  static const _size = 76.0;
  static const _padding = 32.0;

  final Widget icon;

  const VideoIcon({Key key, @required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0),
          ],
        ),
      ),
      child: Padding(
          padding: EdgeInsets.all(_padding),
          child: IconTheme(
            data: IconThemeData(
              color: Colors.white,
              size: _size,
            ),
            child: icon,
          )),
    );
  }
}

class PlayIcon extends StatelessWidget {
  const PlayIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoIcon(
      icon: Icon(Icons.play_circle_outline),
    );
  }
}

class PauseIcon extends StatelessWidget {
  const PauseIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoIcon(
      icon: Icon(Icons.pause_circle_outline),
    );
  }
}
