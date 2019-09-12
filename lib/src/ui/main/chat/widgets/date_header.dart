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

import 'package:flutter/material.dart';
import 'package:pattle/src/ui/main/models/chat_item.dart';
import 'package:pattle/src/ui/resources/theme.dart';
import 'package:pattle/src/ui/util/date_format.dart';

import 'item.dart';

class DateHeader extends Item {
  static const betweenMargin = 8.0;

  @override
  final DateItem item;

  DateHeader(this.item);

  @override
  State<StatefulWidget> createState() => DateHeaderState();
}

class DateHeaderState extends ItemState<DateHeader> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: marginTop(),
          bottom: DateHeader.betweenMargin,
        ),
        child: Stack(
          children: <Widget>[
            Text(
              formatAsDate(context, widget.item.date).toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = chatBackgroundColor(context),
              ),
            ),
            Text(
              formatAsDate(context, widget.item.date).toUpperCase(),
              style: Theme.of(context).textTheme.display1.copyWith(
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double marginTop() => widget.previousItem == null
      ? DateHeader.betweenMargin * 2
      : DateHeader.betweenMargin;
}
