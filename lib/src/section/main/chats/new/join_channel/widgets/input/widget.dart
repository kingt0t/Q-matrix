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
import 'package:mdi/mdi.dart';

import '../../../../../widgets/filled_text_field.dart';

import '../../../../../../../resources/intl/localizations.dart';

import 'bloc.dart';

class ChannelInput extends StatefulWidget {
  final ValueChanged<String> onJoinButtonPressed;
  final ValueChanged<String> onSearchButtonPressed;
  final VoidCallback onClearButtonPressed;

  ChannelInput._({
    @required this.onJoinButtonPressed,
    @required this.onSearchButtonPressed,
    @required this.onClearButtonPressed,
  });

  static Widget withBloc({
    @required ValueChanged<String> onJoinButtonPressed,
    @required ValueChanged<String> onSearchButtonPressed,
    @required VoidCallback onClearButtonPressed,
  }) {
    return BlocProvider<ChannelInputBloc>(
      create: (context) => ChannelInputBloc(),
      child: ChannelInput._(
        onJoinButtonPressed: onJoinButtonPressed,
        onSearchButtonPressed: onSearchButtonPressed,
        onClearButtonPressed: onClearButtonPressed,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ChannelInputState();
}

class _ChannelInputState extends State<ChannelInput> {
  final _controller = TextEditingController();

  void _onChanged(String input) {
    context.bloc<ChannelInputBloc>().add(InputChanged(input));
  }

  void _clear() {
    _controller.clear();
    _onChanged(null);
    widget.onClearButtonPressed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelInputBloc, ChannelInputState>(
      builder: (context, state) {
        return Material(
          elevation: 2,
          color: Theme.of(context).primaryColor,
          child: FilledTextField(
            controller: _controller,
            onChanged: _onChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: state is CanJoin
                ? widget.onJoinButtonPressed
                : widget.onSearchButtonPressed,
            textCapitalization: TextCapitalization.none,
            fillColor: Colors.transparent,
            prefix: SizedBox(width: 8),
            hintText: context.intl.chats.newChat.joinChannel.placeholder,
            suffixIcon: Container(
              width: kMinInteractiveDimension,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.decelerate,
                switchOutCurve: Curves.decelerate.flipped,
                child: state is CanJoin
                    ? IconButton(
                        key: Key('join'),
                        onPressed: () => widget.onJoinButtonPressed(
                          _controller.text,
                        ),
                        icon: Icon(Mdi.locationEnter),
                      )
                    : state is CanClear
                        ? IconButton(
                            key: Key('clear'),
                            onPressed: _clear,
                            icon: Icon(Icons.clear),
                          )
                        : Icon(Icons.search),
              ),
            ),
          ),
        );
      },
    );
  }
}
