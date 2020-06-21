import 'base.dart';

class DummyService implements MessagingService {
  @override
  Future<void> initialize({
    Future Function(Map<String, dynamic>) onMessage,
    Future Function(Map<String, dynamic>) onBackgroundMessage,
  }) async {}

  @override
  Future<String> get token async => null;
}
