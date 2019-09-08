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
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/app.dart';
import 'package:pattle/src/app_bloc.dart';
import 'package:pattle/src/ui/main/chat/chat_bloc.dart';
import 'package:pattle/src/ui/main/chat/util/typing_span.dart';
import 'package:pattle/src/ui/main/chat/widgets/date_header.dart';
import 'package:pattle/src/ui/main/chat/widgets/loading_bubble.dart';
import 'package:pattle/src/ui/main/models/chat_item.dart';
import 'package:pattle/src/ui/main/widgets/chat_name.dart';
import 'package:pattle/src/ui/main/widgets/error.dart';
import 'package:pattle/src/ui/main/widgets/title_with_sub.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/resources/theme.dart';
import 'package:pattle/src/ui/util/color.dart';
import 'package:pattle/src/ui/util/future_or_builder.dart';
import 'package:pattle/src/ui/util/matrix_image.dart';

import 'package:pattle/src/di.dart' as di;
import 'package:pattle/src/ui/util/room.dart';

import 'widgets/bubble.dart';

class ChatPageState extends State<ChatPage> {
  final String _chatBackgroundImagePath = 'chat_background_image_path';
  final me = di.getLocalUser();
  final ChatBloc bloc;
  final Room room;

  ScrollController scrollController = ScrollController();
  double get scrollLoadRange => scrollController.position.maxScrollExtent - 700;

  TextEditingController textController = TextEditingController();

  int maxPageCount;

  Timer readTimer;

  ChatPageState(this.room) : bloc = ChatBloc(room) {
    textController.addListener(() {
      bloc.notifyInputChanged(textController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
    readTimer.cancel();
    textController.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (readTimer != null) {
      readTimer.cancel();
    }

    readTimer = Timer(const Duration(seconds: 2), bloc.markAllAsRead);

    bloc.hasReachedEnd.listen((hasReachedEnd) {
      if (hasReachedEnd) {
        setState(() {
          maxPageCount = bloc.maxPageCount;
        });
      }
    });

    bloc.shouldRefresh.listen((shouldRefresh) {
      setState(() {});
      bloc.markAllAsRead();
    });
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
          backgroundImage: MatrixImage(
            avatarUrl,
            width: 64,
            height: 64,
          ),
        ),
      );
    }

    final settingsGestureDetector = ({Widget child}) {
      return GestureDetector(
        onTap: () => Navigator.of(context)
            .pushNamed(Routes.chatsSettings, arguments: room),
        child: child,
      );
    };

    // TODO: typingUsers should not contain nulls
    Widget title =
        room.isSomeoneElseTyping && !room.typingUsers.any((u) => u == null)
            ? TitleWithSub(
                title: ChatName(room: room),
                subtitle: RichText(
                  text: TextSpan(
                    children: typingSpan(context, room),
                  ),
                ),
              )
            : ChatName(room: room);

    return Scaffold(
      backgroundColor: chatBackgroundColor(context),
      appBar: AppBar(
        titleSpacing: 0,
        title: settingsGestureDetector(
          child: Row(
            children: <Widget>[
              avatar,
              SizedBox(width: 16),
              Expanded(
                child: title,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(AppBloc().storage[_chatBackgroundImagePath])),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            ErrorBanner(),
            Expanded(
              child: _buildBody(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildEventsList(),
        ),
        ConstrainedBox(
          constraints: BoxConstraints.loose(
            Size.fromHeight(
              MediaQuery.of(context).size.height / 3,
            ),
          ),
          child: _buildInput(),
        ),
      ],
    );
  }

  Widget _buildInput() {
    const elevation = 0.0;

    if (bloc.room is JoinedRoom) {
      return Material(
        elevation: elevation,
        //color: chatBackgroundColor(context),
        color: Colors.transparent,
        // On dark theme, draw a divider line because the shadow is gone
        //shape: Theme.of(context).brightness == Brightness.dark
        //    ? Border(top: BorderSide(color: Colors.grey[800]))
        //    : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Material(
            elevation: elevation,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            color: themed(context, light: Colors.white, dark: Colors.grey[800]),
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                filled: true,
                hintText: l(context).typeAMessage,
                prefixIcon: IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () async {
                    await bloc.sendImage(
                      await ImagePicker.pickImage(source: ImageSource.gallery),
                    );
                  },
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    bloc.sendMessage(textController.value.text);
                    textController.clear();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Material(
        elevation: elevation,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            l(context).cantSendMessages,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildEventsList() {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      itemCount: maxPageCount,
      itemBuilder: (BuildContext context, int page) {
        return FutureOrBuilder<List<ChatItem>>(
          futureOr: bloc.getPage(page),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<ChatItem>> snapshot,
          ) {
            Widget widget;

            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                widget = ListView(
                  reverse: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: List.generate(
                    20,
                    (i) => LoadingBubble(
                      room: room,
                      isMine: i % 2 == 0,
                    ),
                  ),
                );
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 2,
                  );
                }

                final chatEvents = snapshot.data;

                final widgets = List<Widget>();
                var i = 0;
                for (final item in chatEvents) {
                  if (item is ChatEvent) {
                    final event = item.event;
                    final isMine = event.sender == me;

                    var previousItem, nextItem;
                    // Note: Because the items are reversed in the
                    // ListView.builder, the 'previous' event is actually the next
                    // one in the list.
                    if (i != chatEvents.length - 1) {
                      previousItem =
                          chatEvents[i + 1] ?? bloc.pages[page - 1].last;
                    }

                    if (i != 0) {
                      nextItem =
                          chatEvents[i - 1] ?? bloc.pages[page + 1].first;
                    }

                    widgets.add(
                      Bubble.fromItem(
                            item: item,
                            previousItem: previousItem,
                            nextItem: nextItem,
                            isMine: isMine,
                          ) ??
                          Container(),
                    );
                  } else if (item is DateItem) {
                    widgets.add(DateHeader(item));
                  }

                  i++;
                }

                widget = ListView(
                  reverse: true,
                  primary: false,
                  shrinkWrap: true,
                  children: widgets,
                );
                break;
            }

            return widget;
          },
        );
      },
    );
  }
}

class ChatPage extends StatefulWidget {
  final Room room;

  ChatPage(this.room);

  @override
  State<StatefulWidget> createState() => ChatPageState(room);
}
