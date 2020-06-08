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

import '../../../../../models/chat.dart';
import '../../../../../models/chat_message.dart';

import '../bubble/message.dart';

import '../../../../../matrix.dart';

import '../../../../../resources/theme.dart';
import '../../../../../resources/intl/localizations.dart';

import 'bloc.dart';

class Input extends StatefulWidget {
  final Chat chat;

  final bool canSendMessages;

  const Input._({
    Key key,
    @required this.chat,
    @required this.canSendMessages,
  }) : super(key: key);

  static Widget withBloc({
    Key key,
    @required Chat chat,
    @required bool canSendMessages,
  }) {
    return BlocProvider<InputBloc>(
      create: (c) => InputBloc(Matrix.of(c), chat.room.id),
      child: Input._(
        key: key,
        chat: chat,
        canSendMessages: canSendMessages,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => InputState();
}

class InputState extends State<Input> with TickerProviderStateMixin {
  final _textController = TextEditingController();

  ChatMessage _replyTo;

  CrossFadeState _crossFadeState;
  Widget _firstChild;
  Widget _secondChild;

  @override
  void initState() {
    super.initState();

    _crossFadeState = CrossFadeState.showFirst;
    _firstChild = Container();
    _secondChild = Container();
  }

  void _notifyInputChanged(String input) {
    context.bloc<InputBloc>().add(NotifyInputChanged(input));
  }

  void _sendMessage() {
    context.bloc<InputBloc>().add(
          SendTextMessage(
            _textController.value.text,
            inReplyTo: _replyTo?.event?.id,
          ),
        );
    _textController.clear();
    // Needed because otherwise auto-capitalization isn't working after
    // sending the first message
    _textController.selection = TextSelection.collapsed(offset: 0);

    clearReplyTo();
  }

  Future<void> _sendImage() async {
    context.bloc<InputBloc>().add(
          SendImageMessage(
            await ImagePicker.pickImage(source: ImageSource.gallery),
          ),
        );

    clearReplyTo();
  }

  void clearReplyTo() => updateReplyTo(null);

  void updateReplyTo(ChatMessage replyTo) {
    if (replyTo?.event?.id != _replyTo?.event?.id) {
      setState(() {
        _replyTo = replyTo;

        final replyToBubble = replyTo != null
            ? Padding(
                key: ValueKey(replyTo.event.id),
                padding: EdgeInsets.only(
                  top: 16,
                  left: kMinInteractiveDimension,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: MessageBubble.withContent(
                          chat: widget.chat,
                          message: replyTo,
                          dense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: clearReplyTo,
                      icon: Icon(Icons.clear),
                      color: Colors.grey,
                    ),
                  ],
                ))
            : Container();

        // Showing first, so going to second
        if (_crossFadeState == CrossFadeState.showFirst) {
          _secondChild = replyToBubble;
          _crossFadeState = CrossFadeState.showSecond;
        } else {
          _firstChild = replyToBubble;
          _crossFadeState = CrossFadeState.showFirst;
        }
      });
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // We use this instead of an AnimatedSize + AnimatedSwitcher so
            // the fade and size transition happen simultaneously
            AnimatedCrossFade(
              duration: Duration(milliseconds: 200),
              firstCurve: Curves.decelerate,
              secondCurve: Curves.decelerate,
              sizeCurve: Curves.decelerate,
              crossFadeState: _crossFadeState,
              firstChild: _firstChild,
              secondChild: _secondChild,
            ),
            Flexible(
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
            ),
          ],
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
