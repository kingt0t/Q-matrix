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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';

import '../../models/chat_member.dart';

import 'messages_all.dart';

class PattleLocalizationsDelegate
    extends LocalizationsDelegate<PattleLocalizations> {
  const PattleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'nl'].contains(locale.languageCode);

  @override
  Future<PattleLocalizations> load(Locale locale) {
    final name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      return PattleLocalizations(localeName);
    });
  }

  @override
  bool shouldReload(PattleLocalizationsDelegate old) => false;
}

extension PattleLocalizationsContext on BuildContext {
  PattleLocalizations get intl => PattleLocalizations.of(this);
}

class PattleLocalizations {
  final String _localeName;

  final _Common common;
  final _Start start;
  final _Chat chat;
  final _Chats chats;
  final _Settings settings;
  final _Error error;
  final _Time time;

  PattleLocalizations(this._localeName)
      : common = _Common(_localeName),
        start = _Start(_localeName),
        chat = _Chat(_localeName),
        chats = _Chats(_localeName),
        settings = _Settings(_localeName),
        error = _Error(_localeName),
        time = _Time(_localeName);

  static PattleLocalizations of(BuildContext context) {
    return Localizations.of<PattleLocalizations>(context, PattleLocalizations);
  }

  String get appName {
    return Intl.message(
      'Pattle',
      name: 'appName',
      locale: _localeName,
    );
  }
}

List<TextSpan> _toTextSpans({
  @required Function function,
  dynamic select,
  @required List<String> args,
  TextStyle style,
}) {
  assert(args.length <= 2);

  final placeholders = List.generate(args.length, (index) => '\$$index');

  final String message = Function.apply(function, [
    if (select != null) select,
    placeholders[0],
    if (args.length >= 2) placeholders[1],
  ]);

  final placeHolderIndexes = List.generate(
    placeholders.length,
    (index) => index,
  );

  final characters = message.characters.toList();

  final pieces = <TextSpan>[];
  var currentPieceIndex = 0;

  final placeholderPieceIndexes = <int, int>{};

  for (var i = 0; i < characters.length; i++) {
    final currentChar = characters[i];
    final nextChar =
        i + 1 < characters.length ? characters.toList()[i + 1] : null;

    final placeholderIndex = nextChar != null ? int.tryParse(nextChar) : null;
    if (placeholderIndex != null &&
        currentChar == r'$' &&
        placeHolderIndexes.contains(placeholderIndex)) {
      placeholderPieceIndexes[currentPieceIndex] = placeholderIndex;

      pieces.add(
        TextSpan(
          text: args[placeholderIndex],
          style: style,
        ),
      );

      // Skip the next char
      i++;
      currentPieceIndex++;
    } else {
      if (pieces.length == currentPieceIndex) {
        pieces.add(TextSpan(text: currentChar));
      } else {
        pieces[currentPieceIndex] = TextSpan(
          text: pieces[currentPieceIndex].text + currentChar,
        );
      }
    }
  }

  return pieces;
}

extension LocalizedTextSpansString on String Function(String) {
  List<TextSpan> toTextSpans(String input, {TextStyle style}) => _toTextSpans(
        function: this,
        args: [input],
        style: style,
      );
}

extension LocalizedTextSpansPerson on String Function(Person, String) {
  List<TextSpan> toTextSpans(
    Person person,
    String name, {
    TextStyle style,
  }) =>
      _toTextSpans(
        function: this,
        select: person,
        args: [name],
        style: style,
      );
}

extension LocalizedTextSpansPersonPair on String Function(
  PersonPair,
  String,
  String,
) {
  List<TextSpan> toTextSpans(
    PersonPair person,
    String firstName,
    String secondName, {
    TextStyle style,
  }) =>
      _toTextSpans(
        function: this,
        select: person,
        args: [firstName, secondName],
        style: style,
      );
}

extension LocalizedTextSpansBool on String Function(
  bool,
  String,
  String,
) {
  List<TextSpan> toTextSpans(
    // ignore: avoid_positional_boolean_parameters
    bool condition,
    String firstName,
    String secondName, {
    TextStyle style,
  }) =>
      _toTextSpans(
        function: this,
        select: condition,
        args: [firstName, secondName],
        style: style,
      );
}

extension ChatMemberPerson on ChatMember {
  Person get person => isYou ? Person.second : Person.third;

  PersonPair personTo(ChatMember other) {
    if (isYou && other.isYou) {
      return PersonPair.secondOnSecond;
    } else if (isYou && !other.isYou) {
      return PersonPair.secondOnThird;
    } else if (!isYou && !other.isYou) {
      return PersonPair.thirdOnThird;
    } else if (!isYou && other.isYou) {
      return PersonPair.thirdOnSecond;
    }

    throw UnsupportedError(
      'Unknown person where this.isYou: $isYou and other.isYou: ${other.isYou}',
    );
  }
}

enum Person {
  second,
  third,
}

enum PersonPair {
  secondOnSecond,
  secondOnThird,
  thirdOnThird,
  thirdOnSecond,
}

class _Category {
  final String _localeName;

  _Category(this._localeName);
}

class _Common extends _Category {
  _Common(String localeName) : super(localeName);

  String get name {
    return Intl.message(
      'Name',
      name: '_Common_name',
      locale: _localeName,
    );
  }

  String get username {
    return Intl.message(
      'Username',
      name: '_Common_username',
      locale: _localeName,
    );
  }

  String get password {
    return Intl.message(
      'Password',
      name: '_Common_password',
      locale: _localeName,
    );
  }

  String get confirm {
    return Intl.message(
      'Confirm',
      name: '_Common_confirm',
      locale: _localeName,
    );
  }

  String get next {
    return Intl.message(
      'Next',
      name: '_Common_next',
      locale: _localeName,
    );
  }

  String get photo {
    return Intl.message(
      'Photo',
      name: '_Common_photo',
      locale: _localeName,
    );
  }

  String get you {
    return Intl.message(
      'You',
      name: '_Common_you',
      desc: 'Used to denote the user using the app instead of their name',
      locale: _localeName,
    );
  }
}

class _Start extends _Category {
  final _StartUsername username;

  _Start(String localeName)
      : username = _StartUsername(localeName),
        super(localeName);

  String get advanced {
    return Intl.message(
      'Advanced',
      name: '_Start_advanced',
      locale: _localeName,
    );
  }

  String get login {
    return Intl.message(
      'Login',
      name: '_Start_login',
      locale: _localeName,
    );
  }

  String get register {
    return Intl.message(
      'Register',
      name: '_Start_register',
      locale: _localeName,
    );
  }

  String get homeserver {
    return Intl.message(
      'Homeserver',
      name: '_Start_homeserver',
      locale: _localeName,
    );
  }

  String get identityServer {
    return Intl.message(
      'Identity server',
      name: '_Start_identityServer',
      locale: _localeName,
    );
  }

  String get loginWithPhone {
    return Intl.message(
      'Login with phone number',
      name: '_Start_loginWithPhone',
      locale: _localeName,
    );
  }

  String get loginWithEmail {
    return Intl.message(
      'Login with email',
      name: '_Start_loginWithEmail',
      locale: _localeName,
    );
  }

  String get loginWithUsername {
    return Intl.message(
      'Login with username',
      name: '_Start_loginWithUsername',
      locale: _localeName,
    );
  }

  String get reportErrorsDescription {
    return Intl.message(
      'Allow Pattle to send crash reports to help development',
      name: '_Start_reportErrorsDescription',
      locale: _localeName,
    );
  }
}

class _StartUsername extends _Category {
  _StartUsername(String localeName) : super(localeName);

  String get title {
    return Intl.message(
      'Enter username',
      name: '_StartUsername_title',
      locale: _localeName,
    );
  }

  String get usernameInvalidError {
    return Intl.message(
      'Invalid username. May only contain letters, numbers, -, ., =, _ and /',
      name: '_StartUsername_usernameInvalidError',
      locale: _localeName,
    );
  }

  String get userIdInvalidError {
    return Intl.message(
      'Invalid user ID. Must be in the format of \'@name:server.tld\'',
      name: '_StartUsername_userIdInvalidError',
      locale: _localeName,
    );
  }

  String get hostnameInvalidError {
    return Intl.message(
      'Invalid hostname',
      name: '_StartUsername_hostnameInvalidError',
      locale: _localeName,
    );
  }

  String get unknownError {
    return Intl.message(
      'An unknown error occured',
      name: '_StartUsername_unknownError',
      locale: _localeName,
    );
  }

  String get wrongPasswordError {
    return Intl.message(
      'Wrong password. Please try again',
      name: '_StartUsername_wrongPasswordError',
      locale: _localeName,
    );
  }
}

class _Chat extends _Category {
  final _ChatMessage message;
  final _ChatDetails details;

  _Chat(String localeName)
      : message = _ChatMessage(localeName),
        details = _ChatDetails(localeName),
        super(localeName);

  String get typeAMessage {
    return Intl.message(
      'Type a message',
      name: '_Chat_typeAMessage',
      desc: 'Hint for the chat input',
      locale: _localeName,
    );
  }

  String get cantSendMessages {
    return Intl.message(
      'You can\'t send messages to this group because'
      ' you\'re no longer a participant.',
      name: '_Chat_cantSendMessages',
      locale: _localeName,
    );
  }

  String get typing {
    return Intl.message(
      'typing...',
      name: '_Chat_typing',
      locale: _localeName,
    );
  }

  String isTyping(String name) {
    return Intl.message(
      '$name is typing...',
      name: '_Chat_isTyping',
      args: [name],
      locale: _localeName,
    );
  }

  // ignore: avoid_positional_boolean_parameters
  String areTyping(bool andMore, String first, String second) {
    return Intl.select(
      andMore,
      {
        false: '$first and $second are typing...',
        true: '$first, $second and more are typing...',
      },
      args: [andMore, first, second],
      name: '_Chat_areTyping',
      locale: _localeName,
    );
  }
}

class _ChatMessage extends _Category {
  _ChatMessage(String localeName) : super(localeName);

  String deletion(Person person, String name) {
    return Intl.select(
      person,
      {
        Person.second: 'You deleted this message',
        Person.third: '$name deleted this message',
      },
      args: [person, name],
      name: '_ChatMessage_deletion',
      locale: _localeName,
    );
  }

  String creation(Person person, String name) {
    return Intl.select(
      person,
      {
        Person.second: 'You created this group',
        Person.third: '$name created this group',
      },
      args: [person, name],
      name: '_ChatMessage_creation',
      locale: _localeName,
    );
  }

  String upgrade(Person person, String name) {
    return Intl.select(
      person,
      {
        Person.second: 'You upgraded this group',
        Person.third: '$name upgraded this group',
      },
      args: [person, name],
      name: '_ChatMessage_upgrade',
      locale: _localeName,
    );
  }

  String descriptionChange(Person person, String name) {
    return Intl.select(
      person,
      {
        Person.second: 'You changed the description of this group',
        Person.third: '$name changed the description of this group',
      },
      args: [person, name],
      name: '_ChatMessage_descriptionChange',
      locale: _localeName,
    );
  }

  String join(Person person, String name) {
    return Intl.select(
      person,
      {
        Person.second: 'You joined',
        Person.third: '$name joined',
      },
      args: [person, name],
      name: '_ChatMessage_join',
      locale: _localeName,
    );
  }

  String leave(Person person, String name) {
    return Intl.select(
      person,
      {
        Person.second: 'You left',
        Person.third: '$name left',
      },
      args: [person, name],
      name: '_ChatMessage_leave',
      locale: _localeName,
    );
  }

  String ban(PersonPair person, String bannee, String banner) {
    return Intl.select(
      person,
      {
        PersonPair.secondOnSecond: 'You were banned by yourself',
        PersonPair.secondOnThird: 'You were banned by $banner',
        PersonPair.thirdOnThird: '$bannee was banned by $banner',
        PersonPair.thirdOnSecond: '$bannee was banned by you',
      },
      args: [person, bannee, banner],
      name: '_ChatMessage_ban',
      locale: _localeName,
    );
  }

  String invite(PersonPair person, String invitee, String inviter) {
    return Intl.select(
      person,
      {
        PersonPair.secondOnSecond: 'You were invited by yourself',
        PersonPair.secondOnThird: 'You were invited by $inviter',
        PersonPair.thirdOnThird: '$invitee was invited by $inviter',
        PersonPair.thirdOnSecond: '$invitee was invited by you',
      },
      args: [person, invitee, inviter],
      name: '_ChatMessage_invite',
      locale: _localeName,
    );
  }
}

class _ChatDetails extends _Category {
  _ChatDetails(String localeName) : super(localeName);

  String get description {
    return Intl.message(
      'Description',
      name: '_ChatDetails_description',
      locale: _localeName,
    );
  }

  String get noDescriptionSet {
    return Intl.message(
      'No description has been set',
      name: '_ChatDetails_noDescriptionSet',
      locale: _localeName,
    );
  }

  String more(int count) {
    return Intl.message(
      '$count more',
      name: '_ChatDetails_more',
      args: [count],
      locale: _localeName,
    );
  }

  String participants(int count) {
    return Intl.plural(
      count,
      zero: 'No participants',
      one: '$count participant',
      other: '$count participants',
      name: '_ChatDetails_participants',
      args: [count],
      locale: _localeName,
    );
  }
}

class _Chats extends _Category {
  final _ChatsNewChat newChat;

  _Chats(String localeName)
      : newChat = _ChatsNewChat(localeName),
        super(localeName);

  String get chats {
    return Intl.message(
      'Chats',
      name: '_Chats_chats',
      locale: _localeName,
    );
  }

  String get channels {
    return Intl.message(
      'Channels',
      name: '_Chats_channels',
      locale: _localeName,
    );
  }
}

class _ChatsNewChat extends _Category {
  final _ChatsNewChatJoinChannel joinChannel;
  final _ChatsNewChatNewGroup newGroup;
  final _ChatsNewChatNewChannel newChannel;

  _ChatsNewChat(String localeName)
      : joinChannel = _ChatsNewChatJoinChannel(localeName),
        newGroup = _ChatsNewChatNewGroup(localeName),
        newChannel = _ChatsNewChatNewChannel(localeName),
        super(localeName);

  String get title {
    return Intl.message(
      'New chat',
      name: '_ChatsNewChat_title',
      locale: _localeName,
    );
  }
}

class _ChatsNewChatNewGroup extends _Category {
  _ChatsNewChatNewGroup(String localeName) : super(localeName);

  String get title {
    return Intl.message(
      'New group',
      name: '_ChatsNewChatNewGroup_title',
      locale: _localeName,
    );
  }

  String get groupName {
    return Intl.message(
      'Group name',
      name: '_ChatsNewChatNewGroup_groupName',
      locale: _localeName,
    );
  }

  String get participants {
    return Intl.message(
      'Participants',
      name: '_ChatsNewChatNewGroup_participants',
      locale: _localeName,
    );
  }
}

class _ChatsNewChatNewChannel extends _Category {
  _ChatsNewChatNewChannel(String localeName) : super(localeName);

  String get title {
    return Intl.message(
      'New channel',
      name: '_ChatsNewChatNewChannel_title',
      locale: _localeName,
    );
  }
}

class _ChatsNewChatJoinChannel extends _Category {
  _ChatsNewChatJoinChannel(String localeName) : super(localeName);

  String get title {
    return Intl.message(
      'Join channel',
      name: '_ChatsNewChatJoinChannel_title',
      locale: _localeName,
    );
  }

  String get placeholder {
    return Intl.message(
      'Search term or alias',
      name: '_ChatsNewChatJoinChannel_placeholder',
      locale: _localeName,
    );
  }

  String get joinButton {
    return Intl.message(
      'Join',
      name: '_ChatsNewChatJoinChannel_joinButton',
      locale: _localeName,
    );
  }
}

class _Settings extends _Category {
  _Settings(String localeName) : super(localeName);

  String get title {
    return Intl.message(
      'Settings',
      name: '_Settings_title',
      desc: 'Settings page title',
      locale: _localeName,
    );
  }

  String get accountTileTitle {
    return Intl.message(
      'Account',
      name: '_Settings_accountTileTitle',
      locale: _localeName,
    );
  }

  String get accountTileSubtitle {
    return Intl.message(
      'Privacy, security, change password',
      name: '_Settings_accountTileSubtitle',
      locale: _localeName,
    );
  }

  String get appearanceTileTitle {
    return Intl.message(
      'Appearance',
      name: '_Settings_appearanceTileTitle',
      locale: _localeName,
    );
  }

  String get appearanceTileSubtitle {
    return Intl.message(
      'Theme, font size',
      name: '_Settings_appearanceTileSubtitle',
      locale: _localeName,
    );
  }

  String get brightnessTileTitle {
    return Intl.message(
      'Brightness',
      name: '_Settings_brightnessTileTitle',
      locale: _localeName,
    );
  }

  String get brightnessTileOptionLight {
    return Intl.message(
      'Light',
      name: '_Settings_brightnessTileOptionLight',
      locale: _localeName,
    );
  }

  String get brightnessTileOptionDark {
    return Intl.message(
      'Dark',
      name: '_Settings_brightnessTileOptionDark',
      locale: _localeName,
    );
  }

  String get profileTitle {
    return Intl.message(
      'Profile',
      locale: _localeName,
    );
  }

  String get editNameDescription {
    return Intl.message(
      'This is not your username.'
      ' This is the name that will be visible to others.',
      name: '_Settings_editNameDescription',
      locale: _localeName,
    );
  }

  String version(String version) {
    return Intl.message(
      'Version $version',
      name: '_Settings_version',
      args: [version],
      locale: _localeName,
    );
  }

  String get logoutButton {
    return Intl.message(
      'Logout',
      locale: _localeName,
    );
  }
}

class _Error extends _Category {
  _Error(String localeName) : super(localeName);

  String get connectionLost {
    return Intl.message(
      'Connection has been lost.\n'
      'Make sure your phone has an active internet connection.',
      name: '_Error_connectionLost',
      locale: _localeName,
    );
  }

  String get connectionFailed {
    return Intl.message(
      'Connection failed.'
      ' Check your internet connection',
      name: '_Error_connectionFailed',
      locale: _localeName,
    );
  }

  String get connectionFailedServerOverloaded {
    return Intl.message(
      'Connection failed.'
      ' The server is probably overloaded.',
      name: '_Error_connectionFailedServerOverloaded',
      locale: _localeName,
    );
  }

  String get anErrorHasOccurred {
    return Intl.message(
      'An error has occurred:',
      name: '_Error_anErrorHasOccurred',
      desc: 'After this message the error is displayed (hence the colon)',
      locale: _localeName,
    );
  }

  String get thisErrorHasBeenReported {
    return Intl.message(
      // TODO: Replace 'Pattle' with appName
      'This error has been reported. Please restart Pattle.',
      name: '_Error_thisErrorHasBeenReported',
      locale: _localeName,
    );
  }
}

class _Time extends _Category {
  _Time(String _localeName) : super(_localeName);

  String get today {
    return Intl.message(
      'Today',
      name: '_Time_today',
      locale: _localeName,
    );
  }

  String get yesterday {
    return Intl.message(
      'Yesterday',
      name: '_Time_yesterday',
      locale: _localeName,
    );
  }
}
