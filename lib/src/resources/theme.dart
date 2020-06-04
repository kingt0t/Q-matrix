// Copyright (C) 2020  Wilko Manger
// Copyright (C) 2020  Cyril Dutrieux <cyril@cdutrieux.fr>
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
import 'package:provider/provider.dart';

import '../models/chat_member.dart';

// TODO: Support branding better

class PattleTheme extends StatefulWidget {
  final Widget child;

  final PattleThemeData data;

  const PattleTheme({
    Key key,
    @required this.data,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PattleThemeState();

  static _PattleThemeDataWithSetter of(
    BuildContext context, {
    bool listen = true,
  }) =>
      Provider.of<_PattleThemeDataWithSetter>(
        context,
        listen: listen,
      );
}

class _PattleThemeState extends State<PattleTheme> {
  _PattleThemeDataWithSetter _dataWithSetter;

  get _light => _PattleThemeDataWithSetter(
        data: pattleLightTheme,
        onBrightnessChanged: _onBrightnessChanged,
      );

  get _dark => _PattleThemeDataWithSetter(
        data: pattleDarkTheme,
        onBrightnessChanged: _onBrightnessChanged,
      );

  @override
  void initState() {
    super.initState();

    _dataWithSetter = _PattleThemeDataWithSetter(
      data: widget.data,
      onBrightnessChanged: _onBrightnessChanged,
    );
  }

  void _onBrightnessChanged(Brightness brightness) {
    setState(() {
      if (brightness == Brightness.light) {
        _dataWithSetter = _light;
      } else {
        _dataWithSetter = _dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<_PattleThemeDataWithSetter>.value(
      value: _dataWithSetter,
      child: widget.child,
    );
  }
}

@immutable
class _PattleThemeDataWithSetter {
  final PattleThemeData data;
  final ValueChanged<Brightness> _onBrightnessChanged;

  const _PattleThemeDataWithSetter({
    @required this.data,
    ValueChanged<Brightness> onBrightnessChanged,
  }) : _onBrightnessChanged = onBrightnessChanged;

  Brightness get brightness => data.themeData.brightness;

  set brightness(Brightness brightness) => _onBrightnessChanged(brightness);
}

extension PattleThemeContext on BuildContext {
  _PattleThemeDataWithSetter get pattleTheme => PattleTheme.of(this);
}

const creteRound = 'CreteRound';

final PattleThemeData pattleLightTheme = PattleThemeData(
  brightness: Brightness.light,
  primaryColorOnBackground: PattleThemeData._primarySwatch[500],
  linkColor: PattleThemeData._primarySwatch,
  listTileIconColor: PattleThemeData._primarySwatch,
  chat: ChatThemeData(
    backgroundColor: PattleThemeData._primarySwatch[50],
    inputColor: Colors.white,
    myMessage: MessageThemeData(
      backgroundColor: PattleThemeData._primarySwatch[450],
      contentColor: Colors.white,
      repliedTo: MessageThemeData(
        backgroundColor: PattleThemeData._primarySwatch[300],
        contentColor: Colors.grey[100],
      ),
    ),
    theirMessage: MessageThemeData(
      backgroundColor: Colors.white,
      contentColor: null,
      repliedTo: MessageThemeData(
        backgroundColor: Colors.grey[250],
        contentColor: Colors.grey[600],
      ),
    ),
    stateMessageColor: PattleThemeData._primarySwatch[100],
    myRedactedContentColor: Colors.grey[300],
    theirRedactedContentColor: Colors.grey[700],
  ),
  markdown: {
    'quote': TextStyle(color: Colors.grey[800]),
    'code': TextStyle(
        color: Colors.grey[800],
        fontFamily: "Monospace",),
    'section': TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,),
    'string': TextStyle(decoration: TextDecoration.underline),
    'symbol': TextStyle(color: Colors.grey[800]),
    'bullet': TextStyle(color: Colors.grey[800]),
    'link': TextStyle(color: Colors.grey[800]),
    'emphasis': TextStyle(fontStyle: FontStyle.italic),
    'strong': TextStyle(fontWeight: FontWeight.w600),
  },
  userColors: {
    DisplayColor.greenYellow: Color(0xFF79740E),
    DisplayColor.yellow: Color(0xFFB57614),
    DisplayColor.blue: Color(0xFF076678),
    DisplayColor.purple: Color(0xFF8F3F71),
    DisplayColor.green: Color(0xFF427B58),
    DisplayColor.red: Color(0xFFAF3A03),
  },
);

final PattleThemeData pattleDarkTheme = PattleThemeData(
  brightness: Brightness.dark,
  primaryColorOnBackground: PattleThemeData._primarySwatch[100],
  linkColor: Colors.white,
  listTileIconColor: PattleThemeData._primarySwatch[400],
  chat: ChatThemeData(
    backgroundColor: Colors.grey[900],
    inputColor: Colors.grey[800],
    myMessage: MessageThemeData(
      backgroundColor: PattleThemeData._primarySwatch[700],
      contentColor: Colors.white,
      repliedTo: MessageThemeData(
        backgroundColor: PattleThemeData._primarySwatch,
        contentColor: Colors.grey[300],
      ),
    ),
    theirMessage: MessageThemeData(
      backgroundColor: Colors.grey[800],
      contentColor: null,
      repliedTo: MessageThemeData(
        backgroundColor: null,
        contentColor: Colors.grey[300],
      ),
    ),
    stateMessageColor: PattleThemeData._primarySwatch[900],
    myRedactedContentColor: Colors.white30,
    theirRedactedContentColor: Colors.white70,
  ),
  markdown: {
    'quote': TextStyle(color: Colors.grey[300]),
    'code': TextStyle(
        color: Colors.grey[300],
        fontFamily: "Monospace",),
    'section': TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,),
    'string': TextStyle(decoration: TextDecoration.underline),
    'symbol': TextStyle(color: Colors.grey[300]),
    'bullet': TextStyle(color: Colors.grey[300]),
    'link': TextStyle(color: Colors.grey[300]),
    'emphasis': TextStyle(fontStyle: FontStyle.italic),
    'strong': TextStyle(fontWeight: FontWeight.w600),
  },
  userColors: {
    DisplayColor.greenYellow: Color(0xFFE7DF35),
    DisplayColor.yellow: Color(0xFFECB258),
    DisplayColor.blue: Color(0xFF25D1F2),
    DisplayColor.purple: Color(0xFFC780AC),
    DisplayColor.green: Color(0xFF81BB98),
    DisplayColor.red: Color(0xFFFB783C),
  },
  themeData: (base) => base.copyWith(
    toggleableActiveColor: PattleThemeData._primarySwatch[400],
    textSelectionHandleColor: PattleThemeData._primarySwatch[400],
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: PattleThemeData._primarySwatch[300],
          ),
        ),
      ),
      labelColor: PattleThemeData._primarySwatch[300],
      labelStyle: base.primaryTextTheme.bodyText1.copyWith(
        fontWeight: FontWeight.bold,
      ),
      // Defaults have to be specified explicitly
      unselectedLabelColor: base.primaryTextTheme.bodyText1.color,
      unselectedLabelStyle: base.primaryTextTheme.bodyText1.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);

class PattleThemeData {
  static const _redPrimary = 0xFFAA4139;
  static const _primarySwatch = MaterialColor(
    _redPrimary,
    <int, Color>{
      50: Color(0xFFf5E8E7),
      100: Color(0xFFE6C6C4),
      200: Color(0xFFD5A09C),
      300: Color(0xFFC47A74),
      400: Color(0xFFB75E57),
      450: Color(0xFFB15048),
      500: Color(_redPrimary),
      600: Color(0xFFA33B33),
      700: Color(0xFF99322C),
      800: Color(0xFF902A24),
      900: Color(0xFF7F1C17),
      1000: Color(0xFF771914),
    },
  );

  final MaterialColor primarySwatch;

  final ThemeData themeData;

  static ThemeData _baseThemeData(
    Brightness brightness,
    MaterialColor primary,
  ) {
    return ThemeData(
      brightness: brightness,
      primarySwatch: primary,
      primaryColorDark: primary[700],
      accentColor: primary,
      primaryColorBrightness: Brightness.dark,
      accentColorBrightness: Brightness.dark,
      cursorColor: primary,
      buttonTheme: ButtonThemeData(
        buttonColor: primary[500],
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  PattleThemeData({
    Brightness brightness = Brightness.light,
    this.primarySwatch = _primarySwatch,
    @required this.primaryColorOnBackground,
    @required this.linkColor,
    @required this.listTileIconColor,
    @required this.chat,
    @required this.markdown,
    @required this.userColors,
    ThemeData Function(ThemeData base) themeData,
  }) : themeData = themeData == null
            ? _baseThemeData(brightness, primarySwatch)
            : themeData(_baseThemeData(brightness, primarySwatch));

  Color get primaryColor => themeData.primaryColor;

  Color get primaryColorLight => themeData.primaryColorLight;

  Color get primaryColorDark => themeData.primaryColorDark;

  final Color primaryColorOnBackground;

  final Color linkColor;

  final Color listTileIconColor;

  final ChatThemeData chat;

  final  Map <String, TextStyle> markdown;

  final Map<DisplayColor, Color> userColors;

  static PattleThemeData of(BuildContext context, {bool listen = true}) =>
      Provider.of<PattleThemeData>(
        context,
        listen: listen,
      );
}

class ChatThemeData {
  final Color backgroundColor;
  final Color inputColor;

  final MessageThemeData myMessage;
  final MessageThemeData theirMessage;

  final Color stateMessageColor;

  final Color myRedactedContentColor;
  final Color theirRedactedContentColor;

  ChatThemeData({
    @required this.backgroundColor,
    @required this.inputColor,
    @required this.myMessage,
    @required this.theirMessage,
    @required this.stateMessageColor,
    @required this.myRedactedContentColor,
    @required this.theirRedactedContentColor,
  });
}

class MessageThemeData {
  final Color backgroundColor;
  final Color contentColor;

  final MessageThemeData repliedTo;

  MessageThemeData({
    @required this.backgroundColor,
    @required this.contentColor,
    this.repliedTo,
  });
}
