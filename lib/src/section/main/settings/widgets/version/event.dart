import 'package:equatable/equatable.dart';

abstract class VersionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetVersion extends VersionEvent {}
