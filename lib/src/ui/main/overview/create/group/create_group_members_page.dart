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
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/app.dart';
import 'package:pattle/src/ui/main/widgets/error.dart';
import 'package:pattle/src/ui/main/widgets/user_avatar.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/util/matrix_image.dart';
import 'package:pattle/src/ui/util/user.dart';

import 'package:pattle/src/ui/main/overview/create/group/create_group_bloc.dart';

class CreateGroupMembersPageState extends State<CreateGroupMembersPage> {

  @override
  void initState() {
    super.initState();

    bloc.loadMembers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).newGroup)
      ),
      body: Column(
        children: <Widget>[
          ErrorBanner(),
          Expanded(
            child: _buildUserList(context)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.chatsNewDetails);
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: bloc.users,
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        final users = snapshot.data;
        if (users != null) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index)
              => _buildUser(context, users[index]),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildUser(BuildContext context, User user) {
    final avatarSize = 42.0;

    Widget avatar = UserAvatar(
      user: user,
      radius: avatarSize * 0.5,
    );

    // TODO: Add checkmark animation
    if (bloc.usersToAdd.contains(user)) {
      avatar = Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          avatar,
          SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Align(
              alignment: Alignment(1.5, 1.5),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              )
            ),
          )
        ],
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(
        displayNameOf(user),
        style: TextStyle(
          fontWeight: FontWeight.w600
        ),
      ),
      onTap: () {
        setState(() {
          if (bloc.usersToAdd.contains(user)) {
            bloc.usersToAdd.remove(user);
          } else {
            bloc.usersToAdd.add(user);
          }
        });
      },
    );
  }
}

class CreateGroupMembersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateGroupMembersPageState();
}