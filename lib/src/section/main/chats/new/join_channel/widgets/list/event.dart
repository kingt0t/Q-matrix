import 'package:equatable/equatable.dart';

abstract class ChannelListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetChannels extends ChannelListEvent {
  final String searchTerm;

  bool get isSearch => searchTerm != null;

  GetChannels([this.searchTerm]);
}
