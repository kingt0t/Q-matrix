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

import 'package:bloc/bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import '../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => Unchecked();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is Check) {
      final user = await LocalUser.fromStore(Matrix.store);

      if (user != null) {
        yield Authenticated(user, fromStore: true);
      } else {
        yield NotAuthenticated();
      }
    } else if (event is LoggedIn) {
      yield Authenticated(event.user, fromStore: false);
    }
  }
}
