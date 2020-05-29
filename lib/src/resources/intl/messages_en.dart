// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef MessageIfAbsent = String Function(
    String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(count) => "${count} more";

  static m1(count) =>
      "${Intl.plural(count, zero: 'No participants', one: '${count} participant', other: '${count} participants')}";

  static m2(person, bannee, banner) => "${Intl.select(person, {
        'secondOnSecond': 'You were banned by yourself',
        'secondOnThird': 'You were banned by ${banner}',
        'thirdOnThird': '${bannee} was banned by ${banner}',
        'thirdOnSecond': '${bannee} was banned by you',
      })}";

  static m3(person, name) => "${Intl.select(person, {
        'second': 'You created this group',
        'third': '${name} created this group',
      })}";

  static m4(person, name) => "${Intl.select(person, {
        'second': 'You deleted this message',
        'third': '${name} deleted this message',
      })}";

  static m5(person, name) => "${Intl.select(person, {
        'second': 'You changed the description of this group',
        'third': '${name} changed the description of this group',
      })}";

  static m6(person, invitee, inviter) => "${Intl.select(person, {
        'secondOnSecond': 'You were invited by yourself',
        'secondOnThird': 'You were invited by ${inviter}',
        'thirdOnThird': '${invitee} was invited by ${inviter}',
        'thirdOnSecond': '${invitee} was invited by you',
      })}";

  static m7(person, name) => "${Intl.select(person, {
        'second': 'You joined',
        'third': '${name} joined',
      })}";

  static m8(person, name) => "${Intl.select(person, {
        'second': 'You left',
        'third': '${name} left',
      })}";

  static m9(person, name) => "${Intl.select(person, {
        'second': 'You upgraded this group',
        'third': '${name} upgraded this group',
      })}";

  static m10(andMore, first, second) => "${Intl.select(andMore, {
        'false': '${first} and ${second} are typing...',
        'true': '${first}, ${second} and more are typing...',
      })}";

  static m11(name) => "${name} is typing...";

  static m12(version) => "Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "Logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "Profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "_ChatDetails_description":
            MessageLookupByLibrary.simpleMessage("Description"),
        "_ChatDetails_more": m0,
        "_ChatDetails_noDescriptionSet":
            MessageLookupByLibrary.simpleMessage("No description has been set"),
        "_ChatDetails_participants": m1,
        "_ChatMessage_ban": m2,
        "_ChatMessage_creation": m3,
        "_ChatMessage_deletion": m4,
        "_ChatMessage_descriptionChange": m5,
        "_ChatMessage_invite": m6,
        "_ChatMessage_join": m7,
        "_ChatMessage_leave": m8,
        "_ChatMessage_upgrade": m9,
        "_Chat_areTyping": m10,
        "_Chat_cantSendMessages": MessageLookupByLibrary.simpleMessage(
            "You can\'t send messages to this group because you\'re no longer a participant."),
        "_Chat_isTyping": m11,
        "_Chat_typeAMessage":
            MessageLookupByLibrary.simpleMessage("Type a message"),
        "_Chat_typing": MessageLookupByLibrary.simpleMessage("typing..."),
        "_ChatsNewChatJoinChannel_joinButton":
            MessageLookupByLibrary.simpleMessage("Join"),
        "_ChatsNewChatJoinChannel_placeholder":
            MessageLookupByLibrary.simpleMessage("Search term or alias"),
        "_ChatsNewChatJoinChannel_title":
            MessageLookupByLibrary.simpleMessage("Join channel"),
        "_ChatsNewChatNewChannel_title":
            MessageLookupByLibrary.simpleMessage("New channel"),
        "_ChatsNewChatNewGroup_groupName":
            MessageLookupByLibrary.simpleMessage("Group name"),
        "_ChatsNewChatNewGroup_participants":
            MessageLookupByLibrary.simpleMessage("Participants"),
        "_ChatsNewChatNewGroup_title":
            MessageLookupByLibrary.simpleMessage("New group"),
        "_ChatsNewChat_title": MessageLookupByLibrary.simpleMessage("New chat"),
        "_Chats_channels": MessageLookupByLibrary.simpleMessage("Channels"),
        "_Chats_chats": MessageLookupByLibrary.simpleMessage("Chats"),
        "_Common_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "_Common_name": MessageLookupByLibrary.simpleMessage("Name"),
        "_Common_next": MessageLookupByLibrary.simpleMessage("Next"),
        "_Common_password": MessageLookupByLibrary.simpleMessage("Password"),
        "_Common_photo": MessageLookupByLibrary.simpleMessage("Photo"),
        "_Common_username": MessageLookupByLibrary.simpleMessage("Username"),
        "_Common_you": MessageLookupByLibrary.simpleMessage("You"),
        "_Error_anErrorHasOccurred":
            MessageLookupByLibrary.simpleMessage("An error has occurred:"),
        "_Error_connectionFailed": MessageLookupByLibrary.simpleMessage(
            "Connection failed. Check your internet connection"),
        "_Error_connectionFailedServerOverloaded":
            MessageLookupByLibrary.simpleMessage(
                "Connection failed. The server is probably overloaded."),
        "_Error_connectionLost": MessageLookupByLibrary.simpleMessage(
            "Connection has been lost.\nMake sure your phone has an active internet connection."),
        "_Error_thisErrorHasBeenReported": MessageLookupByLibrary.simpleMessage(
            "This error has been reported. Please restart Pattle."),
        "_Settings_accountTileSubtitle": MessageLookupByLibrary.simpleMessage(
            "Privacy, security, change password"),
        "_Settings_accountTileTitle":
            MessageLookupByLibrary.simpleMessage("Account"),
        "_Settings_appearanceTileSubtitle":
            MessageLookupByLibrary.simpleMessage("Theme, font size"),
        "_Settings_appearanceTileTitle":
            MessageLookupByLibrary.simpleMessage("Appearance"),
        "_Settings_brightnessTileOptionDark":
            MessageLookupByLibrary.simpleMessage("Dark"),
        "_Settings_brightnessTileOptionLight":
            MessageLookupByLibrary.simpleMessage("Light"),
        "_Settings_brightnessTileTitle":
            MessageLookupByLibrary.simpleMessage("Brightness"),
        "_Settings_editNameDescription": MessageLookupByLibrary.simpleMessage(
            "This is not your username. This is the name that will be visible to others."),
        "_Settings_title": MessageLookupByLibrary.simpleMessage("Settings"),
        "_Settings_version": m12,
        "_StartUsername_hostnameInvalidError":
            MessageLookupByLibrary.simpleMessage("Invalid hostname"),
        "_StartUsername_title":
            MessageLookupByLibrary.simpleMessage("Enter username"),
        "_StartUsername_unknownError":
            MessageLookupByLibrary.simpleMessage("An unknown error occured"),
        "_StartUsername_userIdInvalidError": MessageLookupByLibrary.simpleMessage(
            "Invalid user ID. Must be in the format of \'@name:server.tld\'"),
        "_StartUsername_usernameInvalidError": MessageLookupByLibrary.simpleMessage(
            "Invalid username. May only contain letters, numbers, -, ., =, _ and /"),
        "_StartUsername_wrongPasswordError":
            MessageLookupByLibrary.simpleMessage(
                "Wrong password. Please try again"),
        "_Start_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
        "_Start_homeserver": MessageLookupByLibrary.simpleMessage("Homeserver"),
        "_Start_identityServer":
            MessageLookupByLibrary.simpleMessage("Identity server"),
        "_Start_login": MessageLookupByLibrary.simpleMessage("Login"),
        "_Start_loginWithEmail":
            MessageLookupByLibrary.simpleMessage("Login with email"),
        "_Start_loginWithPhone":
            MessageLookupByLibrary.simpleMessage("Login with phone number"),
        "_Start_loginWithUsername":
            MessageLookupByLibrary.simpleMessage("Login with username"),
        "_Start_register": MessageLookupByLibrary.simpleMessage("Register"),
        "_Start_reportErrorsDescription": MessageLookupByLibrary.simpleMessage(
            "Allow Pattle to send crash reports to help development"),
        "_Time_today": MessageLookupByLibrary.simpleMessage("Today"),
        "_Time_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
        "appName": MessageLookupByLibrary.simpleMessage("Pattle")
      };
}
// ignore_for_file: avoid_catches_without_on_clauses,type_annotate_public_apis,lines_longer_than_80_chars
