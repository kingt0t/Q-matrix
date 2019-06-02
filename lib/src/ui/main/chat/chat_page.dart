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
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/chat/chat_bloc.dart';
import 'package:pattle/src/ui/main/chat/widgets/date_header.dart';
import 'package:pattle/src/ui/main/models/chat_item.dart';
import 'package:pattle/src/ui/main/widgets/chat_name.dart';
import 'package:pattle/src/ui/main/widgets/error.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/resources/theme.dart';
import 'package:pattle/src/ui/util/matrix_image.dart';

import 'package:pattle/src/di.dart' as di;
import 'package:pattle/src/ui/util/room.dart';

import 'widgets/bubble.dart';

class ChatPageState extends State<ChatPage> {

  final me = di.getLocalUser();
  final ChatBloc bloc = ChatBloc();
  final JoinedRoom room;

  ScrollController scrollController = ScrollController();
  double get scrollLoadRange => scrollController.position.maxScrollExtent - 700;

  TextEditingController textController = TextEditingController();

  ChatPageState(this.room) {
    bloc.room = room;
  }

  @override
  void initState() {
    super.initState();
    bloc.startLoadingEvents();

    scrollController.addListener(() {
      if (scrollController.offset >= scrollLoadRange
       && !scrollController.position.outOfRange) {
        bloc.requestMoreEvents();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget avatar = Container();
    final avatarUrl = avatarUrlOf(room);
    if (avatarUrl != null) {
      avatar = Hero(
        tag: room.id,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: MatrixImage(avatarUrl, roundThumbnail: true),
        )
      );
    }

    return Scaffold(
      backgroundColor: LightColors.red[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              padding: EdgeInsets.all(0),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            avatar,
            SizedBox(
              width: 16,
            ),
            Flexible(
              child: ChatName(room: room),
            )
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          ErrorBanner(),
          Expanded(
            child: Stack(
              children: <Widget>[
                _buildBody(),
                _buildLoadingIndicator()
              ],
            ),
          )
        ],
      )
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildEventsList()
        ),
        _buildInput(),
      ],
    );
  }

  Widget _buildInput() {
    return Material(
      elevation: 8,
      color: LightColors.red[50],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            controller: textController,
            textInputAction: TextInputAction.newline,
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8))
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: l(context).typeAMessage,
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  bloc.sendMessage(textController.value.text);
                  textController.clear();
                }
              )
            ),
          ),
        )
      )
    );
  }

  Widget _buildLoadingIndicator() {
    return StreamBuilder<bool>(
      stream: bloc.isLoadingEvents,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final isLoading = snapshot.data ?? false;

        return AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: Duration(milliseconds: 250),
            child: Container(
              alignment: Alignment.topCenter,
              child: RefreshProgressIndicator(),
            )
        );
      }
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<ChatItem>>(
      stream: bloc.items,
      builder: (BuildContext context, AsyncSnapshot<List<ChatItem>> snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            var chatEvents = snapshot.data;
            return ListView.builder(
              controller: scrollController,
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: chatEvents.length,
              itemBuilder: (context, index) {
                final item = chatEvents[index];
                if (item is ChatEvent) {
                  final event = item.event;
                  final isMine = event.sender.isIdenticalTo(me);

                  var previousItem, nextItem;
                  // Note: Because the items are reversed in the
                  // ListView.builder, the 'previous' event is actually the next
                  // one in the list.
                  if (index != chatEvents.length - 1) {
                    previousItem = chatEvents[index + 1];
                  }

                  if (index != 0) {
                    nextItem = chatEvents[index - 1];
                  }

                  return Bubble.fromItem(
                    item: item,
                    previousItem: previousItem,
                    nextItem: nextItem,
                    isMine: isMine,
                  ) ?? Container();
                } else if (item is DateItem) {
                  return DateHeader(item);
                }
              }
            );
        }
      }
    );
  }
}

class ChatPage extends StatefulWidget {

  final Room room;

  ChatPage(this.room);

  @override
  State<StatefulWidget> createState() => ChatPageState(room);
}