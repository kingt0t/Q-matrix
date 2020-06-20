import 'package:equatable/equatable.dart';

abstract class MediaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchImages extends MediaEvent {}
