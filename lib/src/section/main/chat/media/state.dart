import 'package:equatable/equatable.dart';

import '../../../../models/chat_message.dart';

class MediaState extends Equatable {
  final List<ChatMessage> messages;

  MediaState(this.messages);

  @override
  List<Object> get props => [messages];
}
