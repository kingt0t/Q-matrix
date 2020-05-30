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
import 'package:image_picker/image_picker.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import '../../../../../matrix.dart';

import '../../../../../resources/theme.dart';
import '../../../../../resources/intl/localizations.dart';

import 'bloc.dart';

class Input extends StatefulWidget {
  final RoomId roomId;

  final bool canSendMessages;

  const Input._({
    Key key,
    @required this.roomId,
    @required this.canSendMessages,
  }) : super(key: key);

  static Widget withBloc({
    @required RoomId roomId,
    @required bool canSendMessages,
  }) {
    return BlocProvider<InputBloc>(
      create: (c) => InputBloc(Matrix.of(c), roomId),
      child: Input._(roomId: roomId, canSendMessages: canSendMessages),
    );
  }

  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<Input> {
  final _textController = TextEditingController();

  void _notifyInputChanged(String input) {
    context.bloc<InputBloc>().add(NotifyInputChanged(input));
  }

  void _sendMessage() {
    context.bloc<InputBloc>().add(SendTextMessage(_textController.value.text));
    _textController.clear();
    // Needed because otherwise auto-capitalization isn't working after
    // sending the first message
    _textController.selection = TextSelection.collapsed(offset: 0);
  }

  Future<void> _sendImage() async {
    context.bloc<InputBloc>().add(
          SendImageMessage(
            await ImagePicker.pickImage(source: ImageSource.gallery),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    const elevation = 8.0;

    if (widget.canSendMessages) {
      return Material(
        elevation: elevation,
        color: context.pattleTheme.data.chat.inputColor,
        // On dark theme, draw a divider line because the shadow is gone
        shape: Theme.of(context).brightness == Brightness.dark
            ? Border(top: BorderSide(color: Colors.grey[800]))
            : null,
        child: TextField(
          controller: _textController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          textInputAction: TextInputAction.newline,
          autocorrect: true,
          textCapitalization: TextCapitalization.sentences,
          style: DefaultTextStyle.of(context).style.apply(
                fontSizeFactor: 1.2,
              ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.zero,
            ),
            hintText: context.intl.chat.typeAMessage,
            prefixIcon: IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: _sendImage,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ),
          onChanged: _notifyInputChanged,
        ),
      );
    } else {
      return Material(
        elevation: elevation,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            context.intl.chat.cantSendMessages,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }
}
