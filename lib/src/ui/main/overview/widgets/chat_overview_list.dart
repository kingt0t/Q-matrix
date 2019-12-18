// Copyright (C) 2019  Wilko Manger
// Copyright (C) 2019  Joel S
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
import 'package:pattle/src/ui/main/overview/widgets/chat_avatar.dart';
import 'package:pattle/src/ui/main/widgets/chat_name.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/util/date_format.dart';

import 'subtitle.dart';

class ChatOverviewList extends StatefulWidget {
  final Stream<List<ChatOverview>> chats;

  const ChatOverviewList({Key key, this.chats}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatOverviewListState();
}

class ChatOverviewListState extends State<ChatOverviewList> with AutomaticKeepAliveClientMixin<ChatOverviewList> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<ChatOverview>>(
      stream: widget.chats,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<ChatOverview>> snapshot,
      ) {
        Widget widget;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            widget = Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            final chats = snapshot.data;

            if (chats == null || chats.isEmpty) {
              return Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(l(context).newChatPart1),
                  Icon(Icons.chat),
                  Text(l(context).newChatPart2),
                ],
              ));
            }

            widget = Scrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 64,
                ),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return _buildChatOverview(chats[index]);
                },
              ),
            );
            break;
        }

        return widget;
      },
    );
  }

  Widget _buildChatOverview(ChatOverview chat) {
    final time = formatAsListItem(context, chat.latestEvent?.time);

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
                  color: Theme.of(context).textTheme.caption.color,
                ),
          ),
        ],
      ),
      dense: false,
      onTap: () {
        Navigator.pushNamed(context, Routes.chats, arguments: chat.room);
      },
      leading: ChatAvatar(room: chat.room),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      subtitle: Subtitle.forChat(chat),
    );
  }
}
