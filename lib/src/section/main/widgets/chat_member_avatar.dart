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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/chat_member.dart';

import '../../../util/chat_member.dart';
import '../../../util/url.dart';

class ChatMemberAvatar extends StatelessWidget {
  final ChatMember member;
  final double radius;

  ChatMemberAvatar({@required this.member, this.radius});

  @override
  Widget build(BuildContext context) {
    if (member.avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: CachedNetworkImageProvider(
          member.avatarUrl.toHttps(context, thumbnail: true),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: member.color(context),
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
