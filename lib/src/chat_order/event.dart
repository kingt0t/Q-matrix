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

import 'package:equatable/equatable.dart';

import '../models/chat.dart';

abstract class ChatOrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateChatOrder extends ChatOrderEvent {
  final List<Chat> personal;
  final List<Chat> public;

  UpdateChatOrder({
    List<Chat> personal,
    List<Chat> public,
  })  : personal = personal ?? [],
        public = public ?? [];
}
