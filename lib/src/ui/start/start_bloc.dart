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
import 'package:pattle/src/di.dart' as di;
import 'package:rxdart/rxdart.dart';

import 'package:pattle/src/push.dart' as push;

final bloc = StartBloc();

class StartBloc {

  StartBloc() {
    di.registerHomeserverWith(Uri.parse("https://matrix.org"));
  }

  final _homeserverChangedSubj = BehaviorSubject<bool>();
  Observable<bool> get homeserverChanged => _homeserverChangedSubj.stream;

  Homeserver get homeserver => di.getHomeserver();

  Username _username;

  /// Duration after which a progress indicator should be shown.
  static const loadingTime = const Duration(seconds: 3);

  void _setHomeserver(Uri uri) {
    di.registerHomeserverWith(uri);
    _homeserverChangedSubj.add(true);
  }

  void setHomeserverUri(String url) {
    try {
      var uri = Uri.parse(url);

      _setHomeserver(uri);
    } on FormatException {
      _homeserverChangedSubj.addError(InvalidHostnameException());
    }
  }

  final _isUsernameAvailableSubj = ReplaySubject<UsernameAvailableState>(maxSize: 1);
  Observable<UsernameAvailableState> get isUsernameAvailable
    => _isUsernameAvailableSubj.stream.distinct();

  void checkUsernameAvailability(String username) {
    if (username == null) {
      return;
    }

    _isUsernameAvailableSubj.add(UsernameAvailableState.checking);
    // If after three seconds it's still checking, change state to
    // 'stillChecking'.
    Future.delayed(loadingTime).then((_) {
      _isUsernameAvailableSubj.stream.listen((state) {
        if (state == UsernameAvailableState.checking) {
          _isUsernameAvailableSubj.add(UsernameAvailableState.stillChecking);
        }
      });
    });

    var addError = (error) {
      _isUsernameAvailableSubj.addError(error);
      _isUsernameAvailableSubj.add(UsernameAvailableState.none);
    };

    var user;

    // Check if there is a ':' in the username,
    // if so, treat it as a full Matrix ID (with or without '@').
    // Otherwise use the local part (with or without '@').
    // So, accept all of these formats:
    // @joe:matrix.org
    // joe:matrix.org
    // joe
    // @joe
    if (username.contains(':')) {
      final split = username.split(':');
      String server = split[1];

      try {
        final serverUri = Uri.parse("https://$server");
        _setHomeserver(serverUri);

        // Add an '@' if the username does not have one, to allow
        // for this input: 'pit:pattle.im'
        if (!username.startsWith('@')) {
          username = "@$username";
        }

        if (!UserId.isValidFullyQualified(username)) {
          addError(InvalidUserIdException());
          return;
        }

        user = UserId(username).username;
      } on FormatException {
        addError(InvalidHostnameException());
        return;
      }
    } else {
      if (username.startsWith('@')) {
        username = username.substring(1).toLowerCase();
      }

      if (!Username.isValid(username)) {
        addError(InvalidUsernameException());
        return;
      }

      user = Username(username);
    }

    homeserver.isUsernameAvailable(user).then((available) {
      if (available) {
        _isUsernameAvailableSubj.add(UsernameAvailableState.available);
      } else {
        _isUsernameAvailableSubj.add(UsernameAvailableState.unavailable);
      }

      _username = user;
    })
    .catchError((error) => _isUsernameAvailableSubj.addError(error));
  }

  final _loginSubj = BehaviorSubject<LoginState>();
  Observable<LoginState> get loginStream
  => _loginSubj.stream;

  void login(String password) async {
    _loginSubj.add(LoginState.trying);

    // If after three seconds it's still checking, change state to
    // 'stillTrying'.
    Future.delayed(loadingTime).then((_) {
      _loginSubj.stream.listen((state) {
        if (state == LoginState.trying) {
          _loginSubj.add(LoginState.stillTrying);
        }
      });
    });

    final user = await homeserver.login(
          _username,
            password,
          store: di.getStore()
    ).catchError((err){throw err;});
    di.registerLocalUser(user);

    await push.initializePushNotifications();

    _loginSubj.add(LoginState.succeeded);
  }

}

enum UsernameAvailableState {
  none,
  checking,
  stillChecking,
  unavailable,
  available
}

enum LoginState {
  none,
  trying,
  stillTrying,
  succeeded
}

class InvalidUserIdException implements Exception { }

class InvalidHostnameException implements Exception { }