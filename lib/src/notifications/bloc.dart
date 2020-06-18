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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import '../models/chat.dart';
import '../models/chat_member.dart';

import '../auth/bloc.dart';
import '../matrix.dart';

import '../util/url.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final Matrix _matrix;
  final AuthBloc _authBloc;

  StreamSubscription _authSubscription;
  StreamSubscription _receivePortSubscription;

  static const _channelId = 'pattle';
  static const _channelTitle = 'Pattle';
  // TODO: Localize?
  static const _channelDescription = 'Get notified when messages are received';

  /// This port is used purely to detect whether there's another isolate.
  ///
  /// If there is, the background handler will not save it's sync.
  static const _sendPortName = 'notifications';

  final _receivePort = ReceivePort();

  /// SendPort to send the NotificationData to.
  SendPort _sendPort;

  /// RoomId which notifications should not be shown for. Ignored for
  /// background notifications.
  RoomId _hiddenRoomId;

  Future<void> _handlePortMessage(dynamic message) async {
    if (message is SendPort) {
      _sendPort = message;
    }

    if (message is String) {
      final dataMessage = DataMessage.fromJson(json.decode(message));

      final notificationData = await NotificationData.fromDataMessage(
        dataMessage,
        user: _matrix.user,
      ).then((nd) => nd?.toJson());

      if (notificationData != null) {
        _sendPort.send(await json.encode(notificationData));
      }
    }
  }

  NotificationsBloc(this._matrix, this._authBloc) {
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _sendPortName,
    );

    _receivePortSubscription = _receivePort.listen(_handlePortMessage);

    _authSubscription = _authBloc.listen((authState) async {
      if (authState is Authenticated) {
        FirebaseMessaging()
          ..configure(
            onMessage: (message) async {
              final dataMessage = DataMessage.fromJson(message);
              if (dataMessage.roomId == _hiddenRoomId) {
                return;
              }

              await _showNotification(
                await NotificationData.fromDataMessage(
                  dataMessage,
                  user: _matrix.user,
                ),
              );
            },
            onBackgroundMessage: _handleBackgroundMessage,
          );

        if (!authState.fromStore) {
          await _setPusher(authState.user);
        }
        await _authSubscription.cancel();
      }
    });
  }

  @override
  NotificationsState get initialState => Uninitalized();

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    if (event is RemoveNotifications) {
      _removeNotifications(event);
    }

    if (event is HideNotifications) {
      _hiddenRoomId = event.roomId;
    }

    if (event is UnhideNotifications) {
      if (_hiddenRoomId == event.roomId) {
        _hiddenRoomId = null;
      }
    }
  }

  Future<void> _removeNotifications(RemoveNotifications blocEvent) async {
    final plugin = await _getPlugin();

    final room = _matrix.user.rooms[blocEvent.roomId];

    for (final event in room.timeline.reversed) {
      plugin.cancel(event.id.hashCode);
      if (event.id == blocEvent.until) {
        break;
      }
    }
  }

  Future<void> _setPusher(MyUser user) async {
    await DotEnv().load();

    await user.pushers.set(
      HttpPusher(
        appId: 'im.pattle.app',
        appName: 'Pattle',
        deviceName: user.currentDevice.name,
        key: await FirebaseMessaging().getToken(),
        url: Uri.parse(
          DotEnv().env['PUSH_URL'],
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _receivePortSubscription.cancel();
    await super.close();
  }

  static FlutterLocalNotificationsPlugin _plugin;
  static Future<FlutterLocalNotificationsPlugin> _getPlugin() async {
    if (_plugin == null) {
      _plugin = FlutterLocalNotificationsPlugin();
      await _plugin.initialize(
        InitializationSettings(
          AndroidInitializationSettings('notification_icon'),
          IOSInitializationSettings(),
        ),
      );
    }

    return _plugin;
  }

  static Message _eventToMessage(RoomEvent event, Person person) {
    if (event is EmoteMessageEvent) {
      return Message(
        '${person.name} ${event.content.body}',
        event.time,
        person,
      );
    }

    if (event is TextMessageEvent) {
      return Message(
        event.content.body,
        event.time,
        person,
      );
    }

    if (event is ImageMessageEvent) {
      // TODO: Show image
      return Message(
        // TODO: Change
        '📷',
        event.time,
        person,
      );
    }

    return null;
  }

  static Future<void> _showNotification(NotificationData data) async {
    if (data == null) {
      return;
    }

    final plugin = await NotificationsBloc._getPlugin();

    final senderPerson = Person(
      bot: false,
      name: data.senderName,
      icon: data.senderAvatarPath,
      iconSource: IconSource.FilePath,
    );

    if (data.event is MessageEvent) {
      final message = _eventToMessage(data.event, senderPerson);

      if (message == null) {
        return;
      }

      Future<void> show({@required bool isGroupSummary}) async {
        await plugin.show(
          isGroupSummary ? data.roomId.hashCode : data.event.id.hashCode,
          data.chatName,
          message.text,
          NotificationDetails(
            AndroidNotificationDetails(
              _channelId,
              _channelTitle,
              _channelDescription,
              importance: Importance.Max,
              priority: Priority.Max,
              enableVibration: true,
              playSound: true,
              style: AndroidNotificationStyle.Messaging,
              groupKey: data.roomId.toString(),
              setAsGroupSummary: isGroupSummary,
              styleInformation: MessagingStyleInformation(
                senderPerson,
                conversationTitle: !data.isDirect ? await data.chatName : null,
                groupConversation: !data.isDirect,
                messages: [message],
              ),
            ),
            IOSNotificationDetails(),
          ),
        );
      }

      show(isGroupSummary: true);
      show(isGroupSummary: false);
    }
  }
}

Future<void> _handleBackgroundMessage(Map<String, dynamic> message) async {
  final port = IsolateNameServer.lookupPortByName(
    NotificationsBloc._sendPortName,
  );

  NotificationData data;

  // A main isolate is running, request the NotificationData from there
  if (port != null) {
    // Send the data message, indicating that we want to get a NotificationData
    // for it
    final receivePort = ReceivePort();
    final completer = Completer();

    StreamSubscription sub;
    sub = receivePort.listen((message) {
      data = NotificationData.fromJson(json.decode(message));
      sub.cancel();
      receivePort.close();
      completer.complete();
    });

    port.send(receivePort.sendPort);
    port.send(json.encode(message));

    await completer.future;
  } else {
    final user = await MyUser.fromStore(await Matrix.storeLocation);

    data = await NotificationData.fromDataMessage(
      DataMessage.fromJson(message),
      user: user,
    );
  }

  await NotificationsBloc._showNotification(data);
}

class DataMessage {
  final RoomId roomId;
  final EventId eventId;

  DataMessage({@required this.roomId, @required this.eventId});

  factory DataMessage.fromJson(Map<String, dynamic> message) {
    return DataMessage(
      roomId: RoomId(message['data']['room_id']),
      eventId: EventId(message['data']['event_id']),
    );
  }
}

/// Data needed to show a notification
@immutable
class NotificationData {
  final RoomId roomId;
  final String chatName;
  final String chatAvatarPath;
  final bool isDirect;

  final RoomEvent event;

  final String senderName;
  final String senderAvatarPath;

  NotificationData({
    @required this.roomId,
    @required this.chatName,
    @required this.chatAvatarPath,
    @required this.isDirect,
    @required this.event,
    @required this.senderName,
    @required this.senderAvatarPath,
  });

  static Future<NotificationData> fromDataMessage(
    DataMessage message, {
    @required MyUser user,
  }) async {
    if (message.roomId?.value == null || message.eventId?.value == null) {
      return null;
    }

    var room = user.rooms[message.roomId];
    if (room == null) {
      room = await user.rooms.load(
        roomIds: [message.roomId],
      ).then((u) => u.user.rooms[message.roomId]);
    }

    var event = room.timeline[message.eventId];

    if (event == null) {
      final wasSyncing = user.isSyncing;
      if (!wasSyncing) {
        user.startSync();
      }

      final update = await user.updates.firstWhere((u) {
        final deltaTimeline = u.delta.rooms[message.roomId]?.timeline;
        if (deltaTimeline == null) {
          return false;
        }

        return deltaTimeline[message.eventId] != null;
      });

      if (!wasSyncing) {
        user.stopSync();
      }

      room = update.user.rooms[message.roomId];
      event = room.timeline[message.eventId];
    }

    final sender = ChatMember.fromRoomAndUserId(
      room,
      event.senderId,
      isMe: false,
    );

    File senderAvatar;
    if (sender.avatarUrl != null) {
      senderAvatar = await DefaultCacheManager().getSingleFile(
        sender.avatarUrl.toHttpsWith(user.context.homeserver, thumbnail: true),
      );
    }

    final chat = Chat(
      room: room,
      directMember: room.isDirect
          ? ChatMember.fromRoomAndUserId(
              room,
              room.directUserId,
              isMe: user.id != room.directUserId,
            )
          : null,
    );

    File chatAvatar;
    if (chat.avatarUrl != null) {
      chatAvatar = await DefaultCacheManager().getSingleFile(
        chat.avatarUrl.toHttpsWith(user.context.homeserver, thumbnail: true),
      );
    }

    return NotificationData(
      roomId: room.id,
      chatName: chat.name,
      chatAvatarPath: chatAvatar?.path,
      isDirect: room.isDirect,
      event: event,
      senderName: sender.name,
      senderAvatarPath: senderAvatar?.path,
    );
  }

  static const _roomIdKey = 'room_id';
  static const _chatNameKey = 'chat_name';
  static const _chatAvatarPathKey = 'chat_avatar_url';
  static const _isDirectKey = 'is_direct';
  static const _eventKey = 'event';
  static const _senderNameKey = 'sender_name';
  static const _senderAvatarPathKey = 'sender_avatar_url';

  NotificationData.fromJson(Map<String, dynamic> json)
      : this(
          roomId: RoomId(json['room_id']),
          chatName: json[_chatNameKey],
          chatAvatarPath: json[_chatAvatarPathKey],
          isDirect: json[_isDirectKey],
          event: RoomEvent.fromJson(json[_eventKey]),
          senderName: json[_senderNameKey],
          senderAvatarPath: json[_senderAvatarPathKey],
        );

  Map<String, dynamic> toJson() {
    return {
      _roomIdKey: roomId.toString(),
      _chatNameKey: chatName,
      _chatAvatarPathKey: chatAvatarPath?.toString(),
      _isDirectKey: isDirect,
      _eventKey: event.toJson(),
      _senderNameKey: senderName,
      _senderAvatarPathKey: senderAvatarPath?.toString(),
    };
  }
}
