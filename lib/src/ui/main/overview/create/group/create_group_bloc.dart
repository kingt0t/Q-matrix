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
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/sync_bloc.dart';
import 'package:pattle/src/ui/util/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pattle/src/di.dart' as di;

final bloc = CreateGroupBloc();

class CreateGroupBloc {
  final me = di.getLocalUser();

  PublishSubject<List<User>> _userSubj = PublishSubject<List<User>>();
  Stream<List<User>> get users => _userSubj.stream.distinct();

  bool _isCreatingRoom = false;
  PublishSubject<bool> _isCreatingRoomSubj = PublishSubject<bool>();
  Stream<bool> get isCreatingRoom => _isCreatingRoomSubj.stream.distinct();

  final usersToAdd = List<User>();

  String groupName;

  JoinedRoom _createdRoom;
  JoinedRoom get createdRoom => _createdRoom;

  Future<void> loadMembers() async {
    final users = Set<User>();
    // Load members of some rooms, in the future
    // this'll be based on activity and what not
    for (final room in await me.rooms.get(upTo: 10)) {
      for (final user in await room.members.get(upTo: 20)) {
        if (user != me) {
          users.add(user);
        }
      }
    }

    _userSubj.add(users.toList(growable: false)
      ..sort((User a, User b) => displayNameOf(a).compareTo(displayNameOf(b))));
  }

  Future<void> createRoom() async {
    if (!_isCreatingRoom) {
      _isCreatingRoom = true;
      _isCreatingRoomSubj.add(true);
      final id = await me.rooms.create(name: groupName, invitees: usersToAdd);

      // Await the next sync so the room has been processed
      final syncState = await syncBloc.stream.first;
      if (syncState.succeeded) {
        _createdRoom = await me.rooms[id];
      }

      _isCreatingRoom = false;
      _isCreatingRoomSubj.add(false);
    }
  }
}
