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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/resources/theme.dart';
import 'package:pattle/src/di.dart' as di;

const _limit = 28;
String _limited(String name) {
  if (name != null && name.length >= _limit) {
    return name.substring(0, _limit) + ' ...';
  } else {
    return name;
  }
}

/// Get the proper display name for [user].
///
/// If [context] is provided, the local user will be 'You' instead
/// of their actual display name.
///
/// This is however not always desired, mostly only when showing the
/// display name to the end user.
String displayNameOf(User user, [BuildContext context]) =>
    context != null && user == di.getLocalUser()
        ? l(context).you
        : _limited(user?.name) ?? user.id.toString().split(':')[0];

String displayNameOrId(UserId id, String name) =>
    _limited(name) ?? id.toString().split(':')[0];

Color colorOf(BuildContext context, User user) =>
    userColor(context, user.id.hashCode % LightColors.userColors.length);
