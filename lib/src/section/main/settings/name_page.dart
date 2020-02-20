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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pattle/src/resources/localizations.dart';
import 'package:pattle/src/resources/theme.dart';

import '../../../util/user.dart';
import '../../../request_state.dart';
import 'settings_bloc.dart';

class NamePageState extends State<NamePage> {
  final bloc = SettingsBloc();

  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final name = bloc.me.displayName;

    textController.value = TextEditingValue(
      text: name,
      selection: TextSelection(baseOffset: 0, extentOffset: name.length),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> setName() async {
    await bloc.setDisplayName(textController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l(context).name,
          style: TextStyle(
            color: redOnBackground(context),
          ),
        ),
        brightness: Theme.of(context).brightness,
        iconTheme: IconThemeData(
          color: redOnBackground(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: setName,
          )
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: textController,
            autocorrect: false,
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
            ),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.zero,
              ),
              fillColor: LightColors.red,
              focusColor: Colors.white,
            ),
            onSubmitted: (_) => setName(),
          ),
          StreamBuilder<RequestState>(
            stream: bloc.displayNameStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<RequestState> snapshot,
            ) {
              if (snapshot.data == RequestState.active) {
                return LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(LightColors.red[300]),
                  backgroundColor: LightColors.red[100],
                );
              } else {
                return Container(height: 6);
              }
            },
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.info_outline,
                    size: 28,
                    color: Theme.of(context).textTheme.caption.color,
                  ),
                ),
                Expanded(
                  child: Text(
                    l(context).editNameDescription,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NamePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NamePageState();
}
