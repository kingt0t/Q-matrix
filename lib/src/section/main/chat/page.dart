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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import '../../../app.dart';

import '../../../notifications/bloc.dart';
import '../../../resources/theme.dart';
import '../../../models/chat.dart';
import '../chats/widgets/typing_content.dart';
import '../widgets/chat_name.dart';
import '../widgets/title_with_sub.dart';

import '../../../matrix.dart';
import '../../../util/url.dart';

import 'bloc.dart';
import 'widgets/bubble/message.dart';
import 'widgets/bubble/state.dart';
import 'widgets/date_header.dart';
import 'widgets/input/invite/widget.dart';
import 'widgets/input/widget.dart';

class ChatPage extends StatelessWidget {
  final Widget avatar;
  final Widget title;
  final Widget input;
  final Widget body;

  final VoidCallback onAppBarTap;

  const ChatPage({
    Key key,
    this.avatar,
    this.title,
    this.onAppBarTap,
    this.input,
    this.body,
  }) : super(key: key);

  static Widget withBloc(RoomId roomId) => _ChatPageWithBloc.withBloc(roomId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pattleTheme.data.chat.backgroundColor,
      appBar: _InkWellAppBar(
        onTap: onAppBarTap,
        appBar: AppBar(
          leading: SizedBox(
            width: kToolbarHeight,
            height: kToolbarHeight,
          ),
          titleSpacing: 0,
          title: Row(
            children: <Widget>[
              if (avatar != null) avatar,
              SizedBox(width: 16),
              Expanded(
                child: title,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          //ErrorBanner(),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: body,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: MediaQuery.of(context).size.height / 3,
                    minWidth: double.infinity,
                    maxWidth: double.infinity,
                  ),
                  child: input,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatPageWithBloc extends StatefulWidget {
  final RoomId roomId;

  _ChatPageWithBloc(this.roomId);

  static Widget withBloc(RoomId roomId) {
    return BlocProvider<ChatBloc>(
      create: (c) => ChatBloc(
        Matrix.of(c),
        c.bloc<NotificationsBloc>(),
        roomId,
      ),
      child: _ChatPageWithBloc(roomId),
    );
  }

  @override
  State<StatefulWidget> createState() => _ChatPageWithBlocState();
}

class _ChatPageWithBlocState extends State<_ChatPageWithBloc> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bloc = BlocProvider.of<ChatBloc>(context);

    context.bloc<NotificationsBloc>().add(
          HideNotifications(bloc.state.chat.room.id),
        );

    bloc.add(MarkAsRead());
  }

  Future<bool> _onWillPop(BuildContext context, ChatState state) async {
    context.bloc<NotificationsBloc>().add(
          UnhideNotifications(state.chat.room.id),
        );

    return true;
  }

  void _onStateChange(BuildContext context, ChatState state) {
    if (!state.wasTimelineLoad) {
      context.bloc<ChatBloc>().add(MarkAsRead());
    }
  }

  void _goToChatSettings(BuildContext context, ChatState state) {
    Navigator.of(context).pushNamed(
      Routes.chatsSettings,
      arguments: state.chat,
    );

    context.bloc<NotificationsBloc>().add(
          UnhideNotifications(state.chat.room.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: _onStateChange,
      builder: (context, state) {
        final chat = state.chat;
        final isInvite = chat.isInvite;

        Widget avatar = Container();
        final avatarUrl = chat.avatarUrl;
        if (avatarUrl != null) {
          avatar = Hero(
            tag: chat.room.id,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: CachedNetworkImageProvider(
                avatarUrl.toHttps(context, thumbnail: true),
              ),
            ),
          );
        }

        Widget title = chat.room.isSomeoneElseTyping
            ? TitleWithSub(
                title: ChatName(chat: chat),
                subtitle: TypingContent(
                  chat: chat,
                  style: TextStyle(
                    color: Theme.of(context)
                            .appBarTheme
                            .textTheme
                            ?.headline6
                            ?.color ??
                        Theme.of(context).primaryTextTheme.headline6.color,
                  ),
                ),
              )
            : ChatName(chat: chat);

        return WillPopScope(
          onWillPop: () => _onWillPop(context, state),
          child: ChatPage(
            onAppBarTap:
                !isInvite ? () => _goToChatSettings(context, state) : null,
            avatar: avatar,
            title: title,
            body: !isInvite
                ? _MessageList(chat: chat)
                : _InviteSplash(chat: chat),
            input: !isInvite
                ? Input.withBloc(
                    roomId: chat.room.id,
                    canSendMessages: chat.room.me.hasJoined,
                  )
                : InviteInput.withBloc(roomId: chat.room.id),
          ),
        );
      },
    );
  }
}

class _MessageList extends StatefulWidget {
  final Chat chat;

  const _MessageList({Key key, @required this.chat}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final _scrollController = ScrollController();
  final double _scrollThreshold = 200;

  bool _requestingMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bloc = BlocProvider.of<ChatBloc>(context);

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      final state = bloc.state;

      if (maxScroll - currentScroll <= _scrollThreshold &&
          !state.endReached &&
          !_requestingMore) {
        _requestingMore = true;
        bloc.add(LoadMoreFromTimeline());
      }
    });
  }

  void _onStateChange(ChatState state) {
    _requestingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) => _onStateChange(state),
      builder: (context, state) {
        var messages = state.messages;
        if (state.wasTimelineLoad) {
          messages = [...state.newMessages, ...messages];
        } else {
          messages = [...messages, ...state.newMessages];
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.endReached
              ? state.messages.length
              : state.messages.length + 1,
          itemBuilder: (context, index) {
            if (index >= state.messages.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final message = state.messages[index];

            final event = message.event;

            var previousMessage, nextMessage;
            // Note: Because the items are reversed in the
            // ListView.builder, the 'previous' event is actually the next
            // one in the list.
            if (index != state.messages.length - 1) {
              previousMessage = state.messages[index + 1];
            }

            if (index != 0) {
              nextMessage = state.messages[index - 1];
            }

            Widget bubble;
            if (event is StateEvent) {
              bubble = StateBubble.withContent(message: message);
            } else {
              bubble = MessageBubble.withContent(
                chat: widget.chat,
                message: message,
                previousMessage: previousMessage,
                nextMessage: nextMessage,
              );
            }

            // Insert DateHeader if there's a day difference
            if (previousMessage != null &&
                event != null &&
                previousMessage.event.time.day != event.time.day) {
              return DateHeader(
                date: event.time,
                child: bubble,
              );
            } else {
              return bubble;
            }
          },
        );
      },
    );
  }
}

/// Necessary to show the ink ripples on the whole [AppBar] when tapping it.
class _InkWellAppBar extends StatelessWidget implements PreferredSize {
  final PreferredSizeWidget appBar;

  final VoidCallback onTap;

  const _InkWellAppBar({
    Key key,
    @required this.appBar,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        appBar,
        Material(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: double.infinity,
                child: InkWell(
                  onTap: onTap,
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: kToolbarHeight,
                  height: kToolbarHeight,
                  child: Center(
                    child: IconTheme(
                      data: Theme.of(context).appBarTheme.iconTheme ??
                          Theme.of(context).primaryIconTheme,
                      child: BackButton(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget get child => appBar;

  @override
  Size get preferredSize => appBar.preferredSize;
}

class _InviteSplash extends StatelessWidget {
  final Chat chat;

  const _InviteSplash({Key key, @required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 164,
              height: 164,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: Icon(
                Icons.mail,
                size: 96,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        StateBubble.withContent(
          // Latest message should be the invite event
          message: chat.latestMessage,
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
