import 'package:pattle/src/di.dart' as di;

import 'package:pattle/src/notification.dart';

import 'package:push/push.dart';

import 'package:matrix_sdk/matrix_sdk.dart';

const PUSH_TOKEN_KEY = "push-token";

Future<void> initializePushNotifications() async {
  //updateNotifications();
  await PushManager.initialize();
  await registerNewPushToken(await PushManager.getToken());
  await PushManager.setMessageReceivedCallback(messageHandler);
  await PushManager.setNewTokenCallback(registerNewPushToken);
}

Future<void> registerNewPushToken(String token) async {
  di.registerStore();
  final store = di.getStore();
  final localUser = await LocalUser.fromStore(store);

  if (localUser != null) {
    di.registerHomeserver(localUser.homeserver);
    final registeredPushToken = await store.getAppCustomData(PUSH_TOKEN_KEY);
    if (registeredPushToken != token) {
      if (registeredPushToken != null) {
        // TODO to be tested
        // remove old token from the pusher list
        await localUser.setPusher(
            registeredPushToken,
            'https://push.tout.im/_matrix/push/v1/notify',
            'im.pattle.app.android',
            'Pattle',
            'Mobile',
            remove: true);
      }

      // register the new pusher
      final res = await localUser.setPusher(
          token,
          'https://push.tout.im/_matrix/push/v1/notify',
          'im.pattle.app.android',
          'Pattle',
          'Mobile',
          eventIdOnly: true);
      if (res) {
        await store.setAppCustomData(PUSH_TOKEN_KEY, token);
      } else {
        throw PushRegistrationFailedException();
      }
    }
  }
}

messageHandler(PushMessage message) async {
  final data = message.data;
  final roomId = data['room_id'];
  final eventId = data['event_id'];

  if (roomId == null || eventId == null) {return;}

  di.registerStore();
  final localUser = await LocalUser.fromStore(di.getStore());

  if (localUser != null) {
    di.registerHomeserver(localUser.homeserver);

    final room = await localUser.rooms[(RoomId(roomId))];

    // We fetch from the server to have fresh data.
    // We should perhaps fall back on the infos in the push message
    // if the network req fails and the data are available.
    var filter = {
      'room': <String, dynamic> {
        'rooms': [roomId],
        'timeline' : {
          'types': ['m.room.message']
        }
      }
    };
    await localUser.syncOnce(updateSyncToken: false, filter: filter);

    showNotification(room, eventId);
  }
}

class PushRegistrationFailedException implements Exception { }