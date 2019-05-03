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
import 'package:pattle/src/push.dart' as push;
import 'package:respect_24_hour/respect_24_hour.dart';

final bloc = InitialBloc();

class InitialBloc {

  final _loggedInSubj = BehaviorSubject<bool>();
  Observable<bool> get loggedIn
  => _loggedInSubj.stream;

  // General app initialization
  void init() async {
    var use24Hour = await Respect24Hour.get24HourFormat;
    di.registerUse24HourFormat(use24Hour);
  }

  void checkIfLoggedIn() async {
    di.registerStore();
    var localUser = await LocalUser.fromStore(di.getStore());

    if (localUser != null) {
      di.registerLocalUser(localUser);
      push.initializePushNotifications();
    }

    _loggedInSubj.add(localUser != null);
  }
}