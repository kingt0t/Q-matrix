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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:pattle/src/app.dart';
import 'package:pattle/src/ui/main/overview/chat_overview_bloc.dart';
import 'package:pattle/src/ui/main/overview/widgets/chat_overview_list.dart';
import 'package:pattle/src/ui/main/widgets/error.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/resources/theme.dart';

class ChatOverviewPageState extends State<ChatOverviewPage> {

  final personalTab = ChatOverviewList(chats: bloc.personalChats);
  final publicTab = ChatOverviewList(chats: bloc.publicChats);

  void goToCreateGroup() {
    Navigator.of(context).pushNamed(Routes.chatsNew);
  }

  @override
  void initState() {
    super.initState();

    bloc.loadAndListen();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l(context).appName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, Routes.settings),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            ErrorBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  personalTab,
                  publicTab,
                  Container(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: goToCreateGroup,
          child: Icon(Icons.chat),
        ),
        bottomNavigationBar: Material(
          elevation: 16.0,
          child: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.chat_bubble),
                text: l(context).personal,
              ),
              Tab(
                icon: Icon(Mdi.bullhorn),
                text: l(context).public,
              ),
              Tab(
                icon: Icon(Icons.phone),
                text: l(context).calls,
              ),
            ],
            labelColor: LightColors.red,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: LightColors.red,
          ),
        ),
      ),
    );
  }
}

class ChatOverviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatOverviewPageState();
}
