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

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

import '../../../../resources/intl/localizations.dart';

import 'join_channel/page.dart';

class NewChatPage extends StatefulWidget {
  NewChatPage();

  @override
  State<StatefulWidget> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  static const _iconSize = 28.0;
  static const _style = TextStyle(fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.intl.chats.newChat.title),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.group,
              size: _iconSize,
              color: iconColor,
            ),
            title: Text(
              context.intl.chats.newChat.newGroup.title,
              style: _style,
            ),
            onTap: () {},
          ),
          ListTile(
            // TODO: Should be Mid.earthPlus when available?
            leading: Icon(
              Mdi.earth,
              size: _iconSize,
              color: iconColor,
            ),
            title: Text(
              context.intl.chats.newChat.newChannel.title,
              style: _style,
            ),
            onTap: () {},
          ),
          OpenContainer(
            tappable: false,
            closedElevation: 0,
            closedColor: Theme.of(context).scaffoldBackgroundColor,
            closedShape: ContinuousRectangleBorder(),
            closedBuilder: (context, void Function() action) {
              return ListTile(
                leading: Icon(
                  Mdi.earthArrowRight,
                  size: _iconSize,
                  color: iconColor,
                ),
                title: Text(
                  context.intl.chats.newChat.joinChannel.title,
                  style: _style,
                ),
                onTap: action,
              );
            },
            openBuilder: (_, __) => JoinChannelPage(),
          ),
        ],
      ),
    );
  }
}
