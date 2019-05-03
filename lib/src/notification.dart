import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:pattle/src/di.dart' as di;
import 'package:pattle/src/ui/util/matrix_cache_manager.dart';
import 'package:pattle/src/ui/util/room.dart';

const _notifIdKey = "notif-id";
const _notifFirstEventKey = "notif-first-event";
const _notifNextIdKey = "notif-next-id";

updateNotifications() async {
  di.getLocalUser().rooms.all().forEach((Room r) async {
    final notifFirstEventId = await r.getCustomData(di.getStore(), _notifFirstEventKey);
    if (notifFirstEventId != null) {
      await showNotification(r, notifFirstEventId);
    }
  });
}

showNotification(Room room, String eventId) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var notifId = await getCustomDataInt(room, _notifIdKey, defaultVal: -1);
  if (notifId < 0) {
    notifId = await getAndIncrementNextNotifId();
    await room.setCustomData(di.getStore(), _notifIdKey, notifId.toString());
  }

  final firstEventId = await room.getCustomData(di.getStore(), _notifFirstEventKey);

  List<Event> events;
  if (firstEventId != null) {
    final firstEvent = await room.timeline[EventId(firstEventId)];
    events = await room.timeline.upTo(100, to: firstEvent).toList();
  } else {
    events = [await room.timeline[EventId(eventId)]];
    await room.setCustomData(di.getStore(), _notifFirstEventKey, eventId);
  }

  final List<Message> messages = [];
  var fallbackBody = '';
  for (final e in events.reversed) {
    if (e is MessageEvent) {

      var avatarFile;
      if (e.sender.avatarUrl != null) {
        print(e.sender.avatarUrl);
        avatarFile = await cacheManager.getThumbnailFile(e.sender.avatarUrl.toString(), 128, 128);
      }

      var person;
      if (avatarFile != null) {
        person = Person(name: e.sender.name, icon: avatarFile.path, iconSource: IconSource.FilePath);
      } else {
        person = Person(name: e.sender.name);
      }

      if (e is TextMessageEvent) {
        fallbackBody += e.content.body + '\n';
        messages.add(Message(e.content.body, e.time, person));
      } else if (e is ImageMessageEvent) {
        // TODO we need to have the image available on a common storage,
        // so that the notif center can access it for display. Currently only in the app private cache.

        //final imageFile = await cacheManager.getSingleFile(e.content.url.toString());
        //print(Uri.file(imageFile.path).toString());
        //messages.add(Message(e.content.body, e.time, person, dataUri: Uri.file(imageFile.path).toString(), dataMimeType: 'image/*'));
      }
    }
  }

  final roomName = nameOf(room);

  final roomAvatarUrl = avatarUrlOf(room);
  var roomAvatarFile;
  if (roomAvatarUrl != null) {
    roomAvatarFile = await cacheManager.getThumbnailFile(
    room.avatarUrl.toString(),
    128, 128);
  }

  var person;
  if (roomAvatarFile != null) {
    person = Person(name: roomName, icon: roomAvatarFile.path, iconSource: IconSource.FilePath);
  } else {
    person = Person(name: roomName);
  }

  var styleInfo = MessagingStyleInformation(person,
      conversationTitle: roomName,
      groupConversation: !room.isDirect,
      messages: messages);

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'messages', 'Messages', 'Messages',
      importance: Importance.Max,
      priority: Priority.High,
      groupKey: 'im.pattle.app.MESSAGE',
      style: AndroidNotificationStyle.Messaging,
      styleInformation: styleInfo);

  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  return flutterLocalNotificationsPlugin.show(
      notifId, roomName, fallbackBody, platformChannelSpecifics);
}

Future<int> getCustomDataInt(Identifiable i, String key, { int defaultVal = 0 }) async {
  final res = await i.getCustomData(di.getStore(), key);
  if (res == null) {
    return defaultVal;
  }
  return int.parse(res);
}

Future<int> getAndIncrementNextNotifId() async {
  var next = 0;
  final nextStr = await di.getStore().getAppCustomData(_notifNextIdKey);
  if (nextStr != null) {
    next = int.parse(nextStr) + 1;
  }
  await di.getStore().setAppCustomData(_notifNextIdKey, next.toString());
  return next;
}

dismissRoomNotifFirstEvent(Room room) {
  room.setCustomData(di.getStore(), _notifFirstEventKey, null);
}