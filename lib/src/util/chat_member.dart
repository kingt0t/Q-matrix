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

import 'dart:ui';

import 'package:flutter/material.dart';

import '../resources/intl/localizations.dart';
import '../resources/theme.dart';

import '../models/chat_member.dart';

extension ChatMemberExtension on ChatMember {
  Color color(BuildContext context) =>
      context.pattleTheme.data.userColors[displayColor];

  String nameOrYou(BuildContext context) =>
      isYou ? context.intl.common.you : name;
}
