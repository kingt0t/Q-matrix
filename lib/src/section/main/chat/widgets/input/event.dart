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

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

abstract class InputEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class NotifyInputChanged extends InputEvent {
  final String input;

  NotifyInputChanged(this.input);

  @override
  List<Object> get props => [input];
}

class SendTextMessage extends InputEvent {
  final String message;
  final EventId inReplyTo;

  SendTextMessage(this.message, {this.inReplyTo});

  @override
  List<Object> get props => [message];
}

class SendImageMessage extends InputEvent {
  final File file;

  SendImageMessage(this.file);
}
