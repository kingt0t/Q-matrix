// Copyright (C) 2019  Wilko Manger
// Copyright (C) 2019  Mathieu Velten (FLA signed)
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
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:provider/provider.dart';

import '../../../../../../resources/theme.dart';
import '../../../../../../models/chat_message.dart';

import 'content/creation.dart';
import 'content/member_change.dart';
import 'content/name_change.dart';
import 'content/topic_change.dart';
import 'content/upgrade.dart';

import '../../../../../../util/date_format.dart';

class StateBubble extends StatelessWidget {
  final ChatMessage message;
  final Widget child;

  StateBubble({Key key, this.message, this.child}) : super(key: key) {
    assert(message.event is StateEvent);
  }

  /// Create a [StateBubble] with the correct [child] for the given [message].
  factory StateBubble.withContent({
    @required ChatMessage message,
  }) {
    final event = message.event;

    Widget content = Container(); // TODO: Create default unsupported content

    if (event is MemberChangeEvent) {
      content = MemberChangeContent();
    } else if (event is RoomCreationEvent) {
      content = CreationContent();
    } else if (event is RoomNameChangeEvent) {
      content = NameChangeContent();
    } else if (event is TopicChangeEvent) {
      content = TopicChangeContent();
    } else if (event is UpgradeContent) {
      content = UpgradeContent();
    }

    return StateBubble(
      message: message,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Center(
              child: Material(
                elevation: 1,
                color: context.pattleTheme.data.chat.stateMessageColor,
                shape: shape,
                child: InkWell(
                  customBorder: shape,
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Provider<StateBubble>.value(
                          value: this,
                          child: child,
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatAsTime(message.event.time),
                          style: DefaultTextStyle.of(context)
                              .style
                              .apply(fontSizeFactor: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static StateBubble of(BuildContext context) =>
      Provider.of<StateBubble>(context);
}
