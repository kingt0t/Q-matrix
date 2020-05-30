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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/intl/localizations.dart';
import '../../../../resources/theme.dart';

import '../../../../settings/bloc.dart';
import '../widgets/header.dart';

class AppearancePage extends StatefulWidget {
  AppearancePage();

  @override
  State<StatefulWidget> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  void _changeTheme(Brightness brightness) {
    PattleTheme.of(context, listen: false).brightness = brightness;
    context.bloc<SettingsBloc>().add(
          UpdateThemeBrightness(brightness),
        );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.intl.settings.appearanceTileTitle),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(
              brightness == Brightness.light
                  ? Icons.brightness_high
                  : Icons.brightness_3,
              color: context.pattleTheme.data.primaryColorOnBackground,
            ),
            title: Header(context.intl.settings.brightnessTileTitle),
          ),
          RadioListTile(
            groupValue: brightness,
            value: Brightness.light,
            onChanged: _changeTheme,
            title: Text(context.intl.settings.brightnessTileOptionLight),
          ),
          RadioListTile(
            groupValue: brightness,
            value: Brightness.dark,
            onChanged: _changeTheme,
            title: Text(context.intl.settings.brightnessTileOptionDark),
          ),
          Divider(height: 1)
        ],
      ),
    );
  }
}
