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

import '../../../widgets/reverse_app_bar.dart';
import '../../../../../resources/intl/localizations.dart';

import 'channel/page.dart';
import 'widgets/input/widget.dart';
import 'widgets/list/widget.dart';

class JoinChannelPage extends StatefulWidget {
  JoinChannelPage();

  @override
  State<StatefulWidget> createState() => _JoinChannelPageState();
}

class _JoinChannelPageState extends State<JoinChannelPage> {
  String _searchInput;

  void _onClearButtonPressed() {
    setState(() {
      _searchInput = null;
    });
  }

  void _onSearchButtonPressed(String input) {
    setState(() {
      _searchInput = input;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReverseAppBar(
        title: Text(context.intl.chats.newChat.joinChannel.title),
      ),
      body: Column(
        children: [
          ChannelInput.withBloc(
            onClearButtonPressed: _onClearButtonPressed,
            onJoinButtonPressed: (_) {},
            onSearchButtonPressed: _onSearchButtonPressed,
          ),
          Expanded(
            child: ChannelList.withBloc(
              searchTerm: _searchInput,
              channelDetailsPageBuilder: (context, channel) {
                return ChannelPage.withBloc(channel: channel);
              },
            ),
          )
        ],
      ),
    );
  }
}
