// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
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
  String get localeName => 'nl';

  static m0(count) => "${count} meer";

  static m1(count) =>
      "${Intl.plural(count, zero: 'Geen deelnemers', one: '${count} deelnemer', other: '${count} deelnemers')}";

  static m2(person, bannee, banner) => "${Intl.select(person, {
        'secondOnSecond': 'Je bent door jezelf verbannen',
        'secondOnThird': 'Je bent verbannen door ${banner}',
        'thirdOnThird': '${bannee} is verbannen door ${banner}',
        'thirdOnSecond': '${bannee} is verbannen door jou',
      })}";

  static m3(person, name) => "${Intl.select(person, {
        'second': 'Je hebt deze groep gemaakt',
        'third': '${name} heeft deze groep gemaakt',
      })}";

  static m4(person, name) => "${Intl.select(person, {
        'second': 'Je hebt dit bericht verwijderd',
        'third': '${name} heeft dit bericht verwijderd',
      })}";

  static m5(person, name) => "${Intl.select(person, {
        'second': 'Je hebt de beschrijving van de groep aangepast',
        'third': '${name} heeft de beschrijving van de groep aangepast',
      })}";

  static m6(person, invitee, inviter) => "${Intl.select(person, {
        'secondOnSecond': 'Je bent door jezelf uitgenodigd',
        'secondOnThird': 'Je bent uitgenodigd door ${inviter}',
        'thirdOnThird': '${invitee} is uitgenodigd door ${inviter}',
        'thirdOnSecond': '${invitee} is uitgenodigd door jou',
      })}";

  static m7(person, name) => "${Intl.select(person, {
        'second': 'Je bent aan het gesprek toegevoegd',
        'third': '${name} is aan het gesprek toegevoegd',
      })}";

  static m8(person, name) => "${Intl.select(person, {
        'second': 'Je hebt het gesprek verlaten',
        'third': '${name} heeft het gesprek verlaten',
      })}";

  static m10(person, name) => "${Intl.select(person, {
        'second': 'Je hebt deze groep geüpgrade',
        'third': '${name} heeft deze groep geüpgrade',
      })}";

  static m11(andMore, first, second) => "${Intl.select(andMore, {
        'false': '${first} en ${second} typen...',
        'true': '${first}, ${second} en anderen typen...',
      })}";

  static m12(name) => "${name} typt...";

  static m13(version) => "Versie ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "Logout": MessageLookupByLibrary.simpleMessage("Uitloggen"),
        "Profile": MessageLookupByLibrary.simpleMessage("Profiel"),
        "_ChatDetails_description":
            MessageLookupByLibrary.simpleMessage("Beschrijving"),
        "_ChatDetails_more": m0,
        "_ChatDetails_noDescriptionSet": MessageLookupByLibrary.simpleMessage(
            "Er is geen beschrijving ingesteld"),
        "_ChatDetails_participants": m1,
        "_ChatMessage_ban": m2,
        "_ChatMessage_creation": m3,
        "_ChatMessage_deletion": m4,
        "_ChatMessage_descriptionChange": m5,
        "_ChatMessage_invite": m6,
        "_ChatMessage_join": m7,
        "_ChatMessage_leave": m8,
        "_ChatMessage_upgrade": m10,
        "_Chat_areTyping": m11,
        "_Chat_cantSendMessages": MessageLookupByLibrary.simpleMessage(
            "Je kan geen berichten naar deze groep sturen omdat je geen deelnemer meer bent."),
        "_Chat_isTyping": m12,
        "_Chat_typeAMessage":
            MessageLookupByLibrary.simpleMessage("Typ een bericht"),
        "_Chat_typing":
            MessageLookupByLibrary.simpleMessage("aan het typen..."),
        "_ChatsNewChatJoinChannel_joinButton":
            MessageLookupByLibrary.simpleMessage("Deelnemen"),
        "_ChatsNewChatJoinChannel_placeholder":
            MessageLookupByLibrary.simpleMessage("Zoekterm of alias"),
        "_ChatsNewChatJoinChannel_title":
            MessageLookupByLibrary.simpleMessage("Deelnemen aan kanaal"),
        "_ChatsNewChatNewChannel_title":
            MessageLookupByLibrary.simpleMessage("Nieuw kanaal"),
        "_ChatsNewChatNewGroup_groupName":
            MessageLookupByLibrary.simpleMessage("Groepnaam"),
        "_ChatsNewChatNewGroup_participants":
            MessageLookupByLibrary.simpleMessage("Deelnemers"),
        "_ChatsNewChatNewGroup_title":
            MessageLookupByLibrary.simpleMessage("Nieuwe groep"),
        "_ChatsNewChat_title":
            MessageLookupByLibrary.simpleMessage("Nieuwe chat"),
        "_Chats_channels": MessageLookupByLibrary.simpleMessage("Kanalen"),
        "_Chats_chats": MessageLookupByLibrary.simpleMessage("Chats"),
        "_Common_confirm": MessageLookupByLibrary.simpleMessage("Bevestigen"),
        "_Common_name": MessageLookupByLibrary.simpleMessage("Naam"),
        "_Common_next": MessageLookupByLibrary.simpleMessage("Volgende"),
        "_Common_password": MessageLookupByLibrary.simpleMessage("Wachtwoord"),
        "_Common_photo": MessageLookupByLibrary.simpleMessage("Foto"),
        "_Common_username":
            MessageLookupByLibrary.simpleMessage("Gebruikersnaam"),
        "_Common_you": MessageLookupByLibrary.simpleMessage("Jij"),
        "_Error_anErrorHasOccurred":
            MessageLookupByLibrary.simpleMessage("Er is een fout opgetreden:"),
        "_Error_connectionFailed": MessageLookupByLibrary.simpleMessage(
            "Verbinding mislukt. Controleer je internetverbinding"),
        "_Error_connectionFailedServerOverloaded":
            MessageLookupByLibrary.simpleMessage(
                "Verbinding mislukt. De server is waarschijnlijk overbelast."),
        "_Error_connectionLost": MessageLookupByLibrary.simpleMessage(
            "De verbinding is verloren.\nControleer of je telefoon een actieve internetverbinding heeft."),
        "_Error_thisErrorHasBeenReported": MessageLookupByLibrary.simpleMessage(
            "Deze fout is verstuurd. Herstart alsjeblieft Pattle."),
        "_Settings_accountTileSubtitle": MessageLookupByLibrary.simpleMessage(
            "Privacy, beveiling, wachtwoord veranderen"),
        "_Settings_accountTileTitle":
            MessageLookupByLibrary.simpleMessage("Account"),
        "_Settings_appearanceTileSubtitle":
            MessageLookupByLibrary.simpleMessage("Thema, lettergrootte"),
        "_Settings_appearanceTileTitle":
            MessageLookupByLibrary.simpleMessage("Uiterlijk"),
        "_Settings_brightnessTileOptionDark":
            MessageLookupByLibrary.simpleMessage("Donker"),
        "_Settings_brightnessTileOptionLight":
            MessageLookupByLibrary.simpleMessage("Licht"),
        "_Settings_brightnessTileTitle":
            MessageLookupByLibrary.simpleMessage("Helderheid"),
        "_Settings_editNameDescription": MessageLookupByLibrary.simpleMessage(
            "Dit is niet je gebruikersnaam. Deze naam is zichtbaar voor anderen."),
        "_Settings_title": MessageLookupByLibrary.simpleMessage("Instellingen"),
        "_Settings_version": m13,
        "_StartUsername_hostnameInvalidError":
            MessageLookupByLibrary.simpleMessage("Ongeldige hostnaam"),
        "_StartUsername_title":
            MessageLookupByLibrary.simpleMessage("Vul gebruikersnaam in"),
        "_StartUsername_unknownError": MessageLookupByLibrary.simpleMessage(
            "Er is een onbekende fout opgetreden"),
        "_StartUsername_userIdInvalidError": MessageLookupByLibrary.simpleMessage(
            "Ongeldige gebruikers-ID. Moet in het formaat \'@naam:server.tld\'"),
        "_StartUsername_usernameInvalidError": MessageLookupByLibrary.simpleMessage(
            "Ongeldige gebruikersnaam. Mag alleen letters, nummers, -, ., =, _ en / bevatten"),
        "_StartUsername_wrongPasswordError":
            MessageLookupByLibrary.simpleMessage(
                "Verkeerd wachtwoord. Probeer het opnieuw"),
        "_Start_advanced": MessageLookupByLibrary.simpleMessage("Geavanceerd"),
        "_Start_homeserver": MessageLookupByLibrary.simpleMessage("Homeserver"),
        "_Start_identityServer":
            MessageLookupByLibrary.simpleMessage("Identiteitserver"),
        "_Start_login": MessageLookupByLibrary.simpleMessage("Inloggen"),
        "_Start_loginWithEmail":
            MessageLookupByLibrary.simpleMessage("Inloggen met e-mail"),
        "_Start_loginWithPhone":
            MessageLookupByLibrary.simpleMessage("Inloggen met telefoonnummer"),
        "_Start_loginWithUsername":
            MessageLookupByLibrary.simpleMessage("Inloggen met gebruikersnaam"),
        "_Start_register": MessageLookupByLibrary.simpleMessage("Registreren"),
        "_Start_reportErrorsDescription": MessageLookupByLibrary.simpleMessage(
            "Sta Pattle toe om crashinformatie te sturen om ontikkeling te helpen"),
        "_Time_today": MessageLookupByLibrary.simpleMessage("Vandaag"),
        "_Time_yesterday": MessageLookupByLibrary.simpleMessage("Gisteren"),
        "appName": MessageLookupByLibrary.simpleMessage("Pattle")
      };
}
// ignore_for_file: avoid_catches_without_on_clauses,type_annotate_public_apis,lines_longer_than_80_chars
