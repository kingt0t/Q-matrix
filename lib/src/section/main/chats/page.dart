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

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

import '../../../chat_order/bloc.dart';

import '../../../app.dart';
import '../../../resources/intl/localizations.dart';
import '../../../resources/theme.dart';

import '../../../matrix.dart';

import 'widgets/chat_list.dart';
import '../widgets/pattle_logo.dart';

import 'bloc.dart';

class ChatsPage extends StatefulWidget {
  ChatsPage._();

  static Widget withBloc() {
    return BlocProvider<ChatsBloc>(
      create: (context) => ChatsBloc(
        Matrix.of(context),
        context.bloc<ChatOrderBloc>(),
      ),
      child: ChatsPage._(),
    );
  }

  @override
  State<StatefulWidget> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.intl.appName),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.group),
                    SizedBox(width: 8),
                    Text(context.intl.chats.chats.toUpperCase()),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Mdi.earth),
                    SizedBox(width: 8),
                    Text(context.intl.chats.channels.toUpperCase()),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: _Drawer(),
        body: TabBarView(
          children: <Widget>[
            _ChatsTab(personal: true),
            _ChatsTab(personal: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, Routes.chatsNew),
          child: Icon(Icons.chat),
        ),
        // TODO: Use OpenContainer when state bug is fixed
        /*OpenContainer(
          tappable: false,
          closedElevation: 6,
          closedColor:
              Theme.of(context).floatingActionButtonTheme?.backgroundColor ??
                  Theme.of(context).colorScheme?.secondary,
          closedShape: CircleBorder(),
          closedBuilder: (context, void Function() action) {
            return FloatingActionButton(
              onPressed: action,
              child: Icon(Icons.chat),
            );
          },
          openBuilder: (context, void Function() action) {
            return NewChatPage.withBloc();
          },
        ),*/
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  final bool personal;

  const _ChatsTab({Key key, this.personal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBloc, ChatsState>(builder: (context, state) {
      if (state is ChatsLoaded) {
        return ChatList(
          chats: personal ? state.personal : state.public,
          personal: personal,
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    });
  }
}

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: PattleLogo(width: 128),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: context.pattleTheme.data.listTileIconColor,
            ),
            title: Text(context.intl.settings.title),
            onTap: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
    );
  }
}
