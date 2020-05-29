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

import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:meta/meta.dart';

class Channel {
  final RoomId roomId;
  final String name;
  final Uri avatarUrl;

  final String topic;
  final String alias;
  final int memberCount;

  final Homeserver server;

  Channel({
    @required this.roomId,
    @required this.name,
    @required this.avatarUrl,
    @required this.topic,
    @required this.alias,
    @required this.memberCount,
    @required this.server,
  });
}

extension RoomResultToChannel on RoomResult {
  Channel toChannel(Homeserver server) {
    return Channel(
      roomId: id,
      name: name,
      avatarUrl: avatarUrl,
      topic: topic,
      alias: canonicalAlias?.toString(),
      memberCount: joinedMembersCount,
      server: server,
    );
  }
}
