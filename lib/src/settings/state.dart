import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class SettingsState extends Equatable {
  final Brightness themeBrightness;
  final bool sendErrorReports;

  SettingsState({
    @required this.themeBrightness,
    @required this.sendErrorReports,
  });

  @override
  List<Object> get props => [themeBrightness, sendErrorReports];

  SettingsState copyWith({
    Brightness themeBrightness,
    bool sendErrorReports,
  }) {
    return SettingsState(
      themeBrightness: themeBrightness ?? this.themeBrightness,
      sendErrorReports: sendErrorReports ?? this.sendErrorReports,
    );
  }
}
