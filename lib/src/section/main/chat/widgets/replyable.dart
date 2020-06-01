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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class Replyable extends StatefulWidget {
  final VoidCallback onReply;
  final Widget child;

  const Replyable({
    Key key,
    @required this.onReply,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReplyableState();
}

class _ReplyableState extends State<Replyable> with TickerProviderStateMixin {
  final _offsetToReply = 55.0;

  double _offsetX;

  AnimationController _dragEndController;
  Animation<double> _dragEndAnimation;

  @override
  void initState() {
    super.initState();

    _offsetX = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offsetX += details.delta.dx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_offsetX >= _offsetToReply) {
      widget.onReply();
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator) {
          Vibration.vibrate(
            duration: 50,
            amplitude: 10,
          );
        }
      });
    }

    _dragEndController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _dragEndAnimation = Tween<double>(
      begin: _offsetX,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _dragEndController,
        curve: Curves.decelerate,
      ),
    );

    _dragEndController.addListener(() {
      setState(() {
        _offsetX = _dragEndAnimation.value;
      });

      if (_dragEndController.isCompleted) {
        _dragEndAnimation = null;
        _dragEndController.dispose();
        _dragEndController = null;
      }
    });

    _dragEndController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dragEndController?.dispose();
  }
}
