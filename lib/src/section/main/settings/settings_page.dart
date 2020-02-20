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
import 'package:pattle/src/resources/localizations.dart';
import 'package:pattle/src/resources/theme.dart';
import 'package:pattle/src/section/main/widgets/user_avatar.dart';

import '../../../util/user.dart';

import '../../../app.dart';
import 'settings_bloc.dart';

class SettingsPageState extends State<SettingsPage> {
  final bloc = SettingsBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings),
      ),
      body: ListView(
        children: <Widget>[
          Material(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.settingsProfile);
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Hero(
                      tag: bloc.me.id,
                      child: UserAvatar(
                        user: bloc.me,
                        radius: 36,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            bloc.me.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(bloc.me.id.toString())
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.vpn_key, color: LightColors.red),
            title: Text(l(context).account),
            subtitle: Text(l(context).accountDescription),
          ),
          ListTile(
            leading: Icon(Icons.landscape, color: LightColors.red),
            title: Text(l(context).appearance),
            subtitle: Text(l(context).appearanceDescription),
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.settingsAppearance),
          )
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}
