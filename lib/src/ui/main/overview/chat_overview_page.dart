// Copyright (C) 2019  Wilko Manger
// Copyright (C) 2019  Mathieu Velten
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
import 'package:pattle/src/app.dart';
import 'package:pattle/src/ui/main/overview/models/chat_overview.dart';
import 'package:pattle/src/ui/main/overview/chat_overview_bloc.dart';
import 'package:pattle/src/ui/main/widgets/chat_name.dart';
import 'package:pattle/src/ui/main/widgets/error.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/resources/theme.dart';
import 'package:pattle/src/ui/util/date_format.dart';
import 'package:pattle/src/ui/util/matrix_image.dart';
import 'package:pattle/src/ui/util/room.dart';
import 'package:pattle/src/ui/util/user.dart';

import 'widgets/subtitle.dart';

class ChatOverviewPageState extends State<ChatOverviewPage> {

  @override
  void initState() {
    super.initState();

    bloc.startSync();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).appName)
      ),
      body: Column(
        children: <Widget>[
          ErrorBanner(),
          Expanded(
            child: Scrollbar(
              child: _buildOverviewList()
            ),
          )
        ],
      )
    );
  }

  Widget _buildOverviewList() {
    return StreamBuilder<List<ChatOverview>>(
      stream: bloc.chats,
      builder: (BuildContext context, AsyncSnapshot<List<ChatOverview>> snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            final chats = snapshot.data;

            if (chats == null || chats.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 64,
              ),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _buildChatOverview(chats[index]);
              }
            );
        }
      }
    );
  }

  Widget _buildChatOverview(ChatOverview chat) {
    var time = formatAsListItem(context, chat.latestEvent?.time);

    // Avatar
    final avatarUrl = avatarUrlOf(chat.room);
    var avatar;
    if (avatarUrl != null) {
      avatar = Hero(
        tag: chat.room.id,
        child: Container(
          width: 48,
          height: 48,
          child: Image(
              fit: BoxFit.cover,
              image: MatrixImage(avatarUrl, roundThumbnail: true)
            )
        ),
      );
    } else {

      avatar = CircleAvatar(
        foregroundColor: Colors.white,
        backgroundColor: chat.room.isDirect
                        ? colorOf(chat.room.directUser)
                        : LightColors.red[500],
        radius: 24,
        child: Icon(
          chat.room.isDirect ? Icons.person : Icons.group
        )
      );
    }

    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(
            child: ChatName(
              room: chat.room,
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.subtitle.copyWith(
              fontWeight: FontWeight.normal,
              color: Colors.black54
            )
          )
        ]
      ),
      dense: false,
      onTap: () {
        Navigator.pushNamed(context, Routes.chats, arguments: chat.room);
      },
      leading: avatar,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      subtitle: Subtitle.fromEvent(chat.latestEvent)
    );
  }
}

class ChatOverviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatOverviewPageState();
}