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

import 'package:bloc/bloc.dart';

import '../../../../../auth/bloc.dart' as auth;
import '../../../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final Matrix _matrix;
  final auth.AuthBloc _authBloc;

  LogoutBloc(this._matrix, this._authBloc);

  @override
  LogoutState get initialState => LogoutState();

  @override
  Stream<LogoutState> mapEventToState(LogoutEvent event) async* {
    if (event is Logout) {
      yield LoggingOut();

      await _matrix.logout();
      _authBloc.add(auth.LoggedOut());

      yield LoggedOut();
    }
  }
}
