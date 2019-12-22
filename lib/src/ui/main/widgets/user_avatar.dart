// Copyright (C) 2019  wilko
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/util/user.dart';

import '../../util/url.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final double radius;

  UserAvatar({@required this.user, this.radius});

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: CachedNetworkImageProvider(
          user.avatarUrl.toThumbnailString(context),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: colorOf(context, user),
        radius: radius,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: radius,
        ),
      );
    }
  }
}
