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

import 'dart:async';

import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:meta/meta.dart';
import 'package:pattle/src/di.dart' as di;
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import 'package:pedantic/pedantic.dart';

import '../../app_bloc.dart';
import '../../bloc.dart';
import '../../request_state.dart';

typedef Request = void Function(Function addError);
typedef Check = bool Function(Function addError);

class StartBloc extends Bloc {
  static StartBloc _instance;

  StartBloc._() {
    setHomeserverUrl("https://matrix.org");
  }

  factory StartBloc({bool replace = false}) {
    if (_instance == null || replace) {
      _instance = StartBloc._();
    }

    return _instance;
  }
  final _homeserverChangedSubj = BehaviorSubject<bool>();
  Stream<bool> get homeserverChanged => _homeserverChangedSubj.stream;

  bool homeserverSetViaAdvanced = false;
  Homeserver get homeserver => di.getHomeserver();

  Uri _userIdDomain;
  Uri get userIdDomain => _userIdDomain;

  Username _username;
  Username get username => _username;

  /// Duration after which a progress indicator should be shown.
  static const loadingTime = Duration(seconds: 3);

  Future<void> _setHomeserver(Uri url) async {
    await di.registerHomeserverWith(url);
    _homeserverChangedSubj.add(true);
  }

  Future<void> setHomeserverUrl(String url, {bool allowMistake = false}) async {
    try {
      if (!url.startsWith('https://')) {
        url = 'https://$url';
      }
      final parsedUrl = Uri.parse(url);

      await _setHomeserver(parsedUrl);
      _userIdDomain = parsedUrl;
    } on FormatException {
      if (!allowMistake) {
        _homeserverChangedSubj.addError(InvalidHostnameException());
      }
    } on SocketException {
      if (!allowMistake) {
        rethrow;
      }
    }
  }

  final _isUsernameValidSubj = BehaviorSubject<bool>();
  Stream<bool> get isUsernameValid => _isUsernameValidSubj.stream;

  static bool _defaultValidate(Function addError) => true;
  Future<void> _do({
    @required BehaviorSubject<RequestState> subject,
    Function validate = _defaultValidate,
    @required Request request,
  }) async {
    subject.add(RequestState.active);

    // If after three seconds it's still active, change state to
    // 'stillActive'.
    unawaited(Future.delayed(loadingTime).then((_) async {
      if (subject.value == RequestState.active) {
        subject.add(RequestState.stillActive);
      }
    }));

    final addError = (error) {
      subject.addError(error);
    };

    final validated = validate(addError);

    if (!validated) {
      return;
    }

    request(addError);
  }

  Future<void> checkUsernameValidity(String username) async {
    if (username == null) {
      _isUsernameValidSubj.addError(InvalidUsernameException());
      return;
    }

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
        if (!homeserverSetViaAdvanced) {
          final serverUrl = Uri.parse("https://$server");
          await _setHomeserver(serverUrl);
        }

        // Add an '@' if the username does not have one, to allow
        // for this input: 'pit:pattle.im'
        if (!username.startsWith('@')) {
          username = "@$username";
        }

        if (!UserId.isValidFullyQualified(username)) {
          _isUsernameValidSubj.addError(InvalidUserIdException());
          return;
        }

        _username = UserId(username).username;
      } on FormatException {
        _isUsernameValidSubj.addError(InvalidHostnameException());
        return;
      }

      _isUsernameValidSubj.add(true);
      return;
    } else {
      if (username.startsWith('@')) {
        username = username.substring(1).toLowerCase();
      }

      if (!Username.isValid(username)) {
        _isUsernameValidSubj.addError(InvalidUsernameException());
        return;
      }

      _username = Username(username);

      _isUsernameValidSubj.add(true);
      return;
    }
  }

  final _loginSubj = BehaviorSubject<RequestState>();
  Stream<RequestState> get loginStream => _loginSubj.stream;

  void login(String password) {
    _do(
      subject: _loginSubj,
      request: (addError) {
        homeserver
            .login(_username, password,
                store: di.getStore(),
                device: Device(
                  name: 'Pattle ${Platform.isAndroid ? 'Android' : 'iOS'}',
                ))
            .then((user) {
          di.registerLocalUser(user);
          AppBloc().setPusher();
          AppBloc().notifyLogin();
          _loginSubj.add(RequestState.success);
        }).catchError((error) => _loginSubj.addError(error));
      },
    );
  }

  @override
  void dispose() {
    _homeserverChangedSubj.close();
    _loginSubj.close();
    _isUsernameValidSubj.close();
  }
}

class InvalidUserIdException implements Exception {}

class InvalidHostnameException implements Exception {}
