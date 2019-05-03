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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/util/user.dart';
import 'package:pattle/src/di.dart' as di;

Uri avatarUrlOf(Room room)
  => room.avatarUrl ?? (room.isDirect ? room.directUser.avatarUrl : room.avatarUrl);

FutureOr<String> nameOf(Room room, {BuildContext context}) {
  if (room.name != null) {
    return room.name;
  }

  if (room.isDirect) {
    return displayNameOf(room.directUser);
  }

  // TODO: Make upTo FutureOr
  return room.members.upTo(6).toList().then((members) {
    var name = '';
    if (members != null) {
      if (members.length == 1) {
        if (context != null) {
          return l(context).you;
        } else {
          return "You"; // TODO context in notif ??
        }
        // TODO: Check for aliases (public chats)
      } else {
        final nonMeMembers = members = members
          .where((user) => !user.isIdenticalTo(di.getLocalUser()))
          .toList(growable: false);

        var i = 0;
        for (User member in nonMeMembers) {
          if (i > 4) {
            name += ' ${l(context).andOthers}';
            break;
          }

          name += displayNameOf(member);

          if (i != nonMeMembers.length - 1) {
            name += ', ';
          }

          i++;
        }
      }
    } else {
      return room.id.toString();
    }

    return name.isNotEmpty ? name : room.id.toString();
  });
}