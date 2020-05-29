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

import '../../../../chat/page.dart';
import '../../../../widgets/avatar.dart';
import '../../../../../../app.dart';
import '../models/channel.dart';

import '../../../../../../matrix.dart';
import '../../../../../../resources/intl/localizations.dart';

import 'bloc.dart';

class ChannelPage extends StatefulWidget {
  final Channel channel;

  ChannelPage._(this.channel);

  static Widget withBloc({@required Channel channel}) {
    return BlocProvider<ChannelBloc>(
      create: (context) => ChannelBloc(Matrix.of(context), channel),
      child: ChannelPage._(channel),
    );
  }

  @override
  State<StatefulWidget> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  void _join() {
    context.bloc<ChannelBloc>().add(Join());
  }

  void _onStateChange(BuildContext context, ChannelState state) {
    if (state is Joined) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => ChatPage.withBloc(state.roomId),
        ),
        (route) => route.settings.name == Routes.chats,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChannelBloc, ChannelState>(
        listener: _onStateChange,
        builder: (context, state) {
          return ChatPage(
            avatar: widget.channel.avatarUrl != null
                ? Avatar.channel(url: widget.channel.avatarUrl)
                : null,
            title: Text(widget.channel.name),
            body: Center(
              // TODO: Add better splash screen, and/or implement previews
              child: Text(context.intl.chats.newChat.joinChannel.joinButton),
            ),
            input: Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    switchInCurve: Curves.decelerate.flipped,
                    switchOutCurve: Curves.decelerate,
                    child: state is Joining
                        ? LinearProgressIndicator()
                        : SizedBox(height: 6),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton.icon(
                        onPressed: state is NotJoined ? _join : null,
                        icon: Icon(Icons.input),
                        label: Text(
                          'join'.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6) // For symmetry
                ],
              ),
            ),
          );
        });
  }
}
