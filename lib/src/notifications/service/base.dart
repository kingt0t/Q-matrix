abstract class MessagingService {
  Future<void> initialize({
    Future Function(Map<String, dynamic>) onMessage,
    Future Function(Map<String, dynamic>) onBackgroundMessage,
  });

  Future<String> get token;
}
