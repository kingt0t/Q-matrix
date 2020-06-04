import 'package:equatable/equatable.dart';

import '../../../../models/chat_member.dart';

abstract class ChatSettingsState extends Equatable {
  final List<ChatMember> members;

  ChatSettingsState([List<ChatMember> members]) : members = members ?? [];

  @override
  List<Object> get props => [members];
}

// TODO: Move Member stuff to seperate widget and bloc

class ChatSettingsUninitialized extends ChatSettingsState {
  ChatSettingsUninitialized([List<ChatMember> members]) : super(members);
}

class MembersLoading extends ChatSettingsState {
  MembersLoading([List<ChatMember> members]) : super(members);
}

class MembersLoaded extends ChatSettingsState {
  MembersLoaded([List<ChatMember> members]) : super(members);
}
