import 'package:equatable/equatable.dart';

abstract class ChannelInputEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InputChanged extends ChannelInputEvent {
  final String input;

  InputChanged(this.input);
}
