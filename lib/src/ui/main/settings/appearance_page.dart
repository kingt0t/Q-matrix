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
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:pattle/src/ui/main/settings/settings_bloc.dart';
import 'package:pattle/src/ui/resources/theme.dart';

import 'package:pattle/src/ui/main/settings/widgets/header.dart';

class AppearancePageState extends State<AppearancePage> {
  final bloc = SettingsBloc();

  Brightness brightness;

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
    brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    brightness == Brightness.light
                        ? Icons.brightness_high
                        : Icons.brightness_3,
                    color: redOnBackground(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Brightness',
                    style: TextStyle(
                      color: redOnBackground(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
          RadioListTile(
            groupValue: brightness,
            value: Brightness.light,
            onChanged: (brightness) {
              DynamicTheme.of(context).setBrightness(brightness);
            },
            title: Text('Light'),
          ),
          RadioListTile(
            groupValue: brightness,
            value: Brightness.dark,
            onChanged: (brightness) {
              DynamicTheme.of(context).setBrightness(brightness);
            },
            title: Text('Dark'),
          ),
          Divider(height: 1)
        ],
      ),
    );
  }
}

class AppearancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppearancePageState();
}
