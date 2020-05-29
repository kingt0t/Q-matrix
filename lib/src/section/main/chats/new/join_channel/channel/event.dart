import 'package:equatable/equatable.dart';

abstract class ChannelEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Join extends ChannelEvent {}
