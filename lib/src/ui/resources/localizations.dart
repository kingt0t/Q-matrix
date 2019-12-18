// Copyright (C) 2019  Wilko Manger
// Copyright (C) 2019  Joel S
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Strings l(BuildContext context) => AppLocalizations.of(context).strings;

class Strings {
  const Strings();

  // Common //
  final appName = 'Pattle';
  final name = 'Name';
  final advanced = 'Advanced';
  final username = 'Username';
  final password = 'Password';
  final confirm = 'Confirm';
  final login = 'Login';
  final register = 'Register';
  final next = 'Next';
  final homeserver = 'Homeserver';
  final identityServer = 'Identity server';
  final today = 'Today';
  final yesterday = 'Yesterday';
  final photo = 'Photo';
  final typeAMessage = 'Type a message';
  final you = 'You';
  final andOthers = 'and others';
  final newGroup = 'New group';
  final groupName = 'Group name';
  final participants = 'Participants';
  final profile = 'Profile';
  final settings = 'Settings';
  final personal = 'Personal';
  final public = 'Public';
  final calls = 'Calls';

  final description = 'Description';
  final noDescriptionSet = 'No description has been set';

  final cantSendMessages =
      'You can\'t send messages to this group because you\'re no longer a participant.';

  final connectionLost = 'Connection has been lost.\n'
      'Make sure your phone has an active internet connection.';

  final connectionFailed = 'Connection failed. '
      'Check your internet connection';

  final connectionFailedServerOverloaded = 'Connection failed. '
      'The server is probably overloaded.';

  final anErrorHasOccurred = 'An error has occurred:';
  final thisErrorHasBeenReported =
      'This error has been reported. Please restart Pattle.';

  final newChatPart1 = 'Click ';
  final newChatPart2 = ' button to create a new chat';

  final youDeletedThisMessage = 'You deleted this message';

  List<TextSpan> hasDeletedThisMessage(TextSpan name) =>
      [name, TextSpan(text: ' deleted this message')];

  // StartPage //
  final loginWithPhone = 'Login with phone number';
  final loginWithEmail = 'Login with email';
  final loginWithUsername = 'Login with username';

  // StartPage: UsernamePage //
  final enterUsername = 'Enter username';
  final ifYouDontHaveAnAccount =
      "If you don't have an account, we'll create one";
  final usernameInvalidError =
      "Invalid username. May only contain letters, numbers, -, ., =, _ and /";
  final userIdInvalidError =
      "Invalid user ID. Must be in the format of '@name:server.tld'";
  final hostnameInvalidError = 'Invalid hostname';
  final unknownError = 'An unknown error occured';

  final failedUsernameCheckAvailableError =
      'Failed to check if the username is available';
  final wouldYouLikeLoginOrRegister = 'Would you like to login or register?';

  // StartPage: PasswordPage //
  final enterPassword = 'Enter password';
  final wrongPasswordError = 'Wrong password. Please try again';

  String loggingInAs(String name) => 'Logging in as $name';

  // SettingsPage //
  final account = 'Account';
  final accountDescription = 'Privacy, security, change password';

  final appearance = 'Appearance';
  final appearanceDescription = 'Theme, font size';
  final brightness = 'Brightness';
  final light = 'Light';
  final dark = 'Dark';

  final editNameDescription = 'This is not your username.'
      ' This is the name that will be visible to others.';

  // Room creation event
  List<TextSpan> createdThisGroup(TextSpan name) =>
      [name, TextSpan(text: ' created this group')];

  // Room upgrade event
  List<TextSpan> upgradedThisGroup(TextSpan name) =>
      [name, TextSpan(text: ' upgraded this group')];

  // Topic change event
  List<TextSpan> changedDescriptionTapToView(TextSpan name) => [
        name,
        TextSpan(text: ' changed the description of this group. Tap to view')
      ];

  List<TextSpan> changedDescription(TextSpan name) =>
      [name, TextSpan(text: ' changed the description of this group')];

  // Member change events
  List<TextSpan> changedTheirNameTo(TextSpan oldName, TextSpan newName) =>
      [oldName, TextSpan(text: ' changed their name to '), newName];

  List<TextSpan> joined(TextSpan name) => [name, TextSpan(text: ' joined')];

  List<TextSpan> left(TextSpan name) => [name, TextSpan(text: ' left')];

  List<TextSpan> wasBannedBy(TextSpan banee, TextSpan banner) =>
      [banee, TextSpan(text: ' was banned by '), banner];

  List<TextSpan> wasInvitedBy(TextSpan invitee, TextSpan inviter) =>
      [invitee, TextSpan(text: ' was invited by '), inviter];

  // Typing events
  List<TextSpan> get typing => [TextSpan(text: 'typing...')];

  List<TextSpan> isTyping(TextSpan name) => [
        name,
        TextSpan(text: ' is typing...'),
      ];

  List<TextSpan> areTyping(TextSpan first, TextSpan second) => [
        first,
        TextSpan(text: ' and '),
        second,
        TextSpan(text: ' are typing...')
      ];

  List<TextSpan> andMoreAreTyping(TextSpan first, TextSpan second) => [
        first,
        TextSpan(text: ' and '),
        second,
        TextSpan(text: ' and more typing...')
      ];

  String xMore(int count) => '$count more';

  String xParticipants(int count) => '$count participants';
}

class AppLocalizations {
  AppLocalizations(this.locale) {
    switch (locale.languageCode) {
      case 'en':
        _strings = const Strings();
        break;
      default:
        _strings = const Strings();
    }
  }

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Strings _strings;
  Strings get strings => _strings;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
