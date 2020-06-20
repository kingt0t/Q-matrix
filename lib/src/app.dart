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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'matrix.dart';
import 'auth/bloc.dart';
import 'sentry/bloc.dart';
import 'notifications/bloc.dart';
import 'resources/intl/localizations.dart';
import 'resources/theme.dart';

import 'section/main/chat/page.dart';
import 'section/main/chat/media/page.dart';
import 'section/main/chat/settings/page.dart';
import 'section/main/chats/page.dart';
import 'section/main/chats/new/page.dart';
import 'section/main/settings/appearance/page.dart';
import 'section/main/settings/profile/name/page.dart';
import 'section/main/settings/profile/page.dart';
import 'section/main/settings/page.dart';
import 'section/start/page.dart';
import 'section/start/login/username/page.dart';

import 'redirect.dart';
import 'settings/bloc.dart';
import 'chat_order/bloc.dart';

final Map<String, MaterialPageRoute Function(Object)> routes = {
  Routes.root: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.root),
        builder: (context) => Redirect(),
      ),
  Routes.settings: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.settings),
        builder: (context) => SettingsPage(),
      ),
  Routes.settingsProfile: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.settingsProfile),
        builder: (context) => ProfilePage.withGivenBloc(params),
      ),
  Routes.settingsProfileName: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.settingsProfileName),
        builder: (context) => NamePage.withGivenBloc(params),
      ),
  Routes.settingsAppearance: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.settingsAppearance),
        builder: (context) => AppearancePage(),
      ),
  Routes.chats: (arguments) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.chats),
        builder: (context) => arguments is RoomId
            ? ChatPage.withBloc(arguments)
            : ChatsPage.withBloc(),
      ),
  Routes.chatsSettings: (arguments) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.chatsSettings),
        builder: (context) => ChatSettingsPage.withBloc(arguments),
      ),
  Routes.chatsNew: (arguments) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.chatsNew),
        builder: (context) => NewChatPage(),
      ),
  Routes.chatsNewJoinChannel: (arguments) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.chatsNewJoinChannel),
        builder: (context) => NewChatPage(),
      ),
  Routes.image: (dynamic arguments) => MaterialPageRoute(
      settings: RouteSettings(name: Routes.image),
      builder: (context) => MediaPage.withBloc(arguments[0], arguments[1])),
  Routes.login: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.login),
        builder: (context) => StartPage.withBloc(),
      ),
  Routes.loginUsername: (params) => MaterialPageRoute(
        settings: RouteSettings(name: Routes.loginUsername),
        builder: (context) => UsernameLoginPage.withBloc(),
      ),
};

class Routes {
  Routes._();

  static const root = '/';
  static const settings = '/settings';
  static const settingsProfile = '/settings/profile';
  static const settingsProfileName = '/settings/profile/name';
  static const settingsAppearance = '/settings/appearance';
  static const chats = '/chats';
  static const chatsSettings = '/chats/settings';
  static const image = '/image';

  static const login = '/login';
  static const loginAdvanced = '/login/advanced';
  static const loginUsername = '/login/username';

  static const chatsNew = '/chats/new';
  static const chatsNewJoinChannel = '/chats/new/join';
}

class App extends StatelessWidget {
  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();

    final settingsBloc = SettingsBloc(prefs);
    final chatOrderBloc = ChatOrderBloc(prefs);

    final authBloc = AuthBloc(chatOrderBloc);

    App._sentryBloc = SentryBloc(settingsBloc);

    await _sentryBloc.wrap(
      () => runApp(App(settingsBloc, chatOrderBloc, authBloc)),
    );
  }

  App(
    this._settingsBloc,
    this._chatOrderBloc,
    this._authBloc,
  );

  // TODO: EnvBloc
  static String get buildType => DotEnv().env['BUILD_TYPE'];

  static SentryBloc _sentryBloc;

  final ChatOrderBloc _chatOrderBloc;

  final AuthBloc _authBloc;

  final SettingsBloc _settingsBloc;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: _authBloc,
        ),
        BlocProvider<SentryBloc>.value(
          value: _sentryBloc,
        ),
        BlocProvider<SettingsBloc>.value(
          value: _settingsBloc,
        ),
        BlocProvider<ChatOrderBloc>.value(
          value: _chatOrderBloc,
        ),
      ],
      child: Provider<Matrix>(
        create: (_) => Matrix(_authBloc, _chatOrderBloc),
        child: PattleTheme(
          data: _settingsBloc.state.themeBrightness == Brightness.dark
              ? pattleDarkTheme
              : pattleLightTheme,
          child: Builder(
            builder: (c) {
              return BlocProvider<NotificationsBloc>(
                create: (context) => NotificationsBloc(Matrix.of(c), _authBloc),
                lazy: false,
                child: MaterialApp(
                  onGenerateTitle: (context) => context.intl.appName,
                  localizationsDelegates: [
                    const PattleLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: [
                    const Locale('en', 'US'),
                    const Locale('nl', 'NL')
                  ],
                  initialRoute: Routes.root,
                  onGenerateRoute: (settings) {
                    return routes[settings.name](settings.arguments);
                  },
                  theme: PattleTheme.of(c).data.themeData,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
