// Copyright (C) 2020  wilko
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
import 'package:mdi/mdi.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../resources/theme.dart';
import '../../../util/url.dart';

class Avatar extends StatelessWidget {
  final Uri url;
  final double radius;
  final Color placeholderColor;

  final _AvatarType _type;

  const Avatar._({
    Key key,
    this.url,
    double radius,
    this.placeholderColor,
    @required _AvatarType type,
  })  : _type = type,
        radius = radius ?? 24,
        super(key: key);

  Avatar.direct({
    Key key,
    Uri url,
    double radius,
    Color placeholderColor,
  }) : this._(
          key: key,
          url: url,
          radius: radius,
          placeholderColor: placeholderColor,
          type: _AvatarType.direct,
        );

  Avatar.group({
    Key key,
    Uri url,
    double radius,
    Color placeholderColor,
  }) : this._(
          key: key,
          url: url,
          radius: radius,
          placeholderColor: placeholderColor,
          type: _AvatarType.group,
        );

  Avatar.channel({
    Key key,
    Uri url,
    double radius,
    Color placeholderColor,
  }) : this._(
          key: key,
          url: url,
          radius: radius,
          placeholderColor: placeholderColor,
          type: _AvatarType.channel,
        );

  @override
  Widget build(BuildContext context) {
    final placeholder = _PlaceholderAvatar(
      type: _type,
      color: placeholderColor,
    );

    if (url != null) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: MemoryImage(kTransparentImage),
            image: CachedNetworkImageProvider(
              url.toHttps(context, thumbnail: true),
            ),
            imageErrorBuilder: (context, error, stackTrace) {
              return placeholder;
            },
          ),
        ),
      );
    } else {
      return placeholder;
    }
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  final _AvatarType type;
  final double radius;
  final Color color;

  const _PlaceholderAvatar({
    Key key,
    @required this.type,
    this.radius,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      foregroundColor: Colors.white,
      backgroundColor: color ?? context.pattleTheme.data.primarySwatch[500],
      radius: radius,
      child: _icon,
    );
  }

  Icon get _icon {
    switch (type) {
      case _AvatarType.direct:
        return Icon(Icons.person);
      case _AvatarType.group:
        return Icon(Icons.group);
      case _AvatarType.channel:
        return Icon(Mdi.earth);
    }

    throw UnsupportedError('Unknown type: $type');
  }
}

enum _AvatarType {
  direct,
  group,
  channel,
}
