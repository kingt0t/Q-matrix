import 'package:firebase_messaging/firebase_messaging.dart';

import 'base.dart';

class FirebaseService implements MessagingService {
  @override
  Future<void> initialize({
    Future Function(Map<String, dynamic>) onMessage,
    Future Function(Map<String, dynamic>) onBackgroundMessage,
  }) async {
    FirebaseMessaging().configure(
      onMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
    );
  }

  @override
  Future<String> get token => FirebaseMessaging().getToken();
}
