// Copyright (C) 2019  Wilko Manger
//
// This file is part of Pattle.
//
// Pattle is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pattle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Pattle.  If not, see <https://www.gnu.org/licenses/>.

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _preferences;

  SettingsBloc(this._preferences);

  static const _brightnessKey = 'brightness';
  static const _sendErrorReportsKey = 'send_error_reports';

  @override
  SettingsState get initialState {
    final brightnessIndex = _preferences.getInt(_brightnessKey);
    final sendErrorReports = _preferences.getBool(_sendErrorReportsKey);

    return SettingsState(
      themeBrightness: brightnessIndex != null
          ? Brightness.values[brightnessIndex]
          : Brightness.light,
      sendErrorReports: sendErrorReports ?? false,
    );
  }

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is UpdateThemeBrightness) {
      _preferences.setInt(_brightnessKey, event.value.index);
      yield state.copyWith(
        themeBrightness: event.value,
      );
    }

    if (event is UpdateSendErrorReports) {
      _preferences.setBool(_sendErrorReportsKey, event.value);
      yield state.copyWith(
        sendErrorReports: event.value,
      );
    }
  }
}
