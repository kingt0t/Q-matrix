// Copyright (C) 2020  Wilko Manger
// Copyright (C) 2020  Cyril Dutrieux <cyril@cdutrieux.fr>
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

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:markdown/markdown.dart';

import '../../../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'state.dart';
export 'event.dart';

class InputBloc extends Bloc<InputEvent, InputState> {
  // Doesn't need the most up to date room instance.
  final Room _room;

  InputBloc(
    Matrix matrix,
    RoomId roomId,
  ) : _room = matrix.chats[roomId].room;

  @override
  InputState get initialState => InputState();

  @override
  Stream<InputState> mapEventToState(InputEvent event) async* {
    if (event is NotifyInputChanged) {
      _notifyInputChanged(event.input);
    }

    if (event is SendTextMessage) {
      _sendMessage(event.message, event.inReplyTo);
    }

    if (event is SendImageMessage) {
      await _sendImage(event.file);
    }
  }

  bool _notifying = false;
  bool _typing = false;
  final _stopwatch = Stopwatch();
  Timer _notTypingTimer;
  String _lastInput;
  Future<void> _notifyInputChanged(String input) async {
    if (!_notifying) {
      // Ignore null -> to '' input, triggers when clicking
      // on the textfield
      if (_lastInput == null && input.isEmpty) return;

      _lastInput = input;

      _notifying = true;

      _notTypingTimer?.cancel();

      if (_stopwatch.elapsed >= const Duration(seconds: 4) ||
          !_stopwatch.isRunning) {
        _typing = true;

        await _room.setIsTyping(true, timeout: const Duration(seconds: 7));

        _stopwatch.reset();
        _stopwatch.start();
      }

      _notifying = false;
    }

    _notTypingTimer = Timer(const Duration(seconds: 5), () async {
      if (_typing) {
        _typing = false;
        await _room.setIsTyping(false);
      }
    });
  }

  void _sendMessage(String text, EventId inReplyTo) async {
    // TODO: Check if text is just whitespace
    if (text.isNotEmpty) {
      /*
       Converts to html, automatically escaping +,- except if it was already
      escaped
       */
      final formatted = markdownToHtml(
        text.replaceAllMapped(RegExp(r'(\\)([+-]\s+)'), (m) => '\\${m[2]}'),
        extensionSet: ExtensionSet.commonMark,
      );
      _room
          .send(
            TextMessage(
              body: text,
              inReplyToId: inReplyTo,
              format: "org.matrix.custom.html",
              formattedBody: formatted,
            ),
          )
          .forEach((_) {});
    }
  }

  Future<void> _sendImage(File file) async {
    final message = ImageMessage(
      url: Uri.file(file.path),
      body: file.path.split(Platform.pathSeparator).last,
    );

    _room.send(message).forEach((_) {});
  }
}
