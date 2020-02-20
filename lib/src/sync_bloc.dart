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
import 'package:rxdart/rxdart.dart';

import 'package:pattle/src/di.dart' as di;
import 'package:pedantic/pedantic.dart';

final syncBloc = SyncBloc();

class SyncBloc {
  LocalUser _user = di.getLocalUser();

  ReplaySubject<SyncState> _syncSubj = ReplaySubject<SyncState>(maxSize: 1);
  Stream<SyncState> get stream => _syncSubj.stream;

  Future<void> start() async {
    if (!_user.isSyncing) {
      await _user.sendAllUnsent();

      _user.startSync();
      unawaited(_syncSubj.addStream(_user.sync));
    }
  }

  Future<void> stop() async {
    _user.stopSync();
  }
}
