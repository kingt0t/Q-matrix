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

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'bloc.dart';

class ChatOrderState extends Equatable {
  final Map<RoomId, SortData> personal;
  final Map<RoomId, SortData> public;

  ChatOrderState({@required this.personal, @required this.public});

  @override
  List<Object> get props => [personal, public];
}
