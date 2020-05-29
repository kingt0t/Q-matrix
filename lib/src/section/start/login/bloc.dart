import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import '../bloc.dart';
import '../../../auth/bloc.dart';
import '../../../sentry/bloc.dart';

import '../../../matrix.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final StartBloc _startBloc;
  final AuthBloc _authBloc;
  final SentryBloc _sentryBloc;

  LoginBloc(this._startBloc, this._authBloc, this._sentryBloc);

  CancelableCompleter _changeHomeserverCompleter;

  @override
  LoginState get initialState => NotLoggedIn(
        homeserverState: HomeserverState.initial(),
        usernameState: UsernameState(),
      );

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is ChangeHomeserver) {
      final homeserverState = await _changeHomeserver(event);
      if (homeserverState != null) {
        yield NotLoggedIn(
          usernameState: state.usernameState,
          homeserverState: homeserverState,
        );
      }
    }

    if (event is ChangeUsername) {
      yield await _changeUsername(event);
    }

    if (event is PasswordChanged) {
      yield* _passwordChanged(event);
    }

    if (event is Login) {
      yield* _login(event);
    }
  }

  Stream<LoginState> _login(Login event) async* {
    yield LoggingIn(state);
    try {
      final user = await state.homeserverState.value.login(
        state.usernameState.value,
        event.password,
        store: await Matrix.storeLocation,
        device: Device(
          name: 'Pattle ${Platform.isAndroid ? 'Android' : 'iOS'}',
        ),
        isolated: true,
      );

      _startBloc.add(ProgressToNextStep());
      _authBloc.add(LoggedIn(user));
      _sentryBloc.add(Initialize());
      yield LoginSuccessful.from(state, user: user);
    } on ForbiddenException {
      yield LoginFailed.from(state);
    } on SocketException {
      // TODO: SocketExceptions
    }
  }

  Stream<LoginState> _passwordChanged(PasswordChanged event) async* {
    if (state is LoginFailed) {
      yield NotLoggedIn.from(state);
    }
  }

  Future<HomeserverState> _changeHomeserver(ChangeHomeserver event) async {
    final homeserverState = state.homeserverState;

    // Reset if the user clears the homeserver explicitly, meaning
    // that the homeserver can be set by the host part of the user id again.
    if (event.setExplicitly && event.url == 'https://') {
      return HomeserverState.initial();
    }

    if (homeserverState.isSetExplicitly && !event.setExplicitly) {
      return null;
    }

    final url = Uri.tryParse(event.url);

    if (url == null ||
        !url.isAbsolute ||
        url.authority == null ||
        url.authority.isEmpty) {
      return homeserverState.copyWith(
        isValid: false,
      );
    }

    if (url == homeserverState.value?.url) {
      return null;
    }

    Homeserver homeserver;

    try {
      homeserver = await Homeserver.fromWellKnown(url);
    } on Exception {
      homeserver = Homeserver(url);
    }

    return homeserverState.copyWith(
      value: homeserver,
      isSetExplicitly: event.setExplicitly,
      isValid: true,
    );
  }

  Future<LoginState> _changeUsername(ChangeUsername event) async {
    final currentState = state as NotLoggedIn;

    HomeserverState defaultHomeserverStateIfNotExplicit() {
      if (!state.homeserverState.isSetExplicitly) {
        return HomeserverState.initial();
      } else {
        return null;
      }
    }

    LoginState resetUsername(InvalidReason reason) {
      return currentState.copyWith(
        usernameState: currentState.usernameState.copyWith(
          value: null,
          invalidReason: reason,
        ),
      );
    }

    LoginState resetHomeserverAndUsername(InvalidReason reason) {
      return currentState.copyWith(
        usernameState: currentState.usernameState.copyWith(
          value: null,
          invalidReason: InvalidReason.empty,
        ),
        homeserverState: defaultHomeserverStateIfNotExplicit(),
      );
    }

    var input = event.username;
    if (input == null || input.isEmpty) {
      return resetHomeserverAndUsername(InvalidReason.empty);
    }

    // Check if there is a ':' in the username,
    // if so, treat it as a full Matrix ID (with or without '@').
    // Otherwise use the local part (with or without '@').
    // So, accept all of these formats:
    // @joe:matrix.org
    // joe:matrix.org
    // joe
    // @joe
    final isFullId = input.contains(':');
    final server = isFullId ? input.split(':')[1] : null;

    if (isFullId && server.isNotEmpty) {
      // Add an '@' if the username does not have one, to allow
      // for this input: 'pit:pattle.im'
      if (!input.startsWith('@')) {
        input = "@$input";
      }

      if (!UserId.isValidFullyQualified(input)) {
        return resetHomeserverAndUsername(InvalidReason.userId);
      }

      await _changeHomeserverCompleter?.operation?.cancel();
      _changeHomeserverCompleter = CancelableCompleter();
      _changeHomeserverCompleter.operation.value.whenComplete(
        () => add(
          ChangeHomeserver(
            'https://$server',
            setExplicitly: false,
          ),
        ),
      );

      Future.delayed(
        Duration(seconds: 1),
        _changeHomeserverCompleter.complete,
      );

      return currentState.copyWith(
        usernameState: currentState.usernameState.copyWith(
          value: UserId(input).username,
          isValid: true,
        ),
      );
    } else {
      if (input.startsWith('@')) {
        input = input.substring(1).toLowerCase();
      }

      if (isFullId) {
        input = input.replaceFirst(':', '');
      }

      if (!Username.isValid(input)) {
        return resetUsername(InvalidReason.username);
      }

      return currentState.copyWith(
        usernameState: currentState.usernameState.copyWith(
          value: Username(input),
          isValid: true,
        ),
        homeserverState: defaultHomeserverStateIfNotExplicit(),
      );
    }
  }
}
