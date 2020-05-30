// Copyright (C) 2020  Wilko Manger
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../resources/intl/localizations.dart';

import '../../../../../auth/bloc.dart' hide LoggedOut;
import '../../../../../app.dart';
import '../../../../../matrix.dart';

import 'bloc.dart';

class LogoutButton extends StatelessWidget {
  LogoutButton._({Key key});

  static Widget withBloc() {
    return BlocProvider<LogoutBloc>(
      create: (context) => LogoutBloc(
        Matrix.of(context),
        context.bloc<AuthBloc>(),
      ),
      child: LogoutButton._(),
    );
  }

  void _onStateChange(BuildContext context, LogoutState state) {
    if (state is LoggedOut) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (_) => false,
      );
    }
  }

  void _logout(BuildContext context) {
    context.bloc<LogoutBloc>().add(Logout());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutBloc, LogoutState>(
      listener: _onStateChange,
      builder: (context, state) {
        final isLoggingOut = state is LoggingOut;

        const iconSize = 24.0;

        return FlatButton.icon(
          onPressed: !isLoggingOut ? () => _logout(context) : null,
          icon: AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: !isLoggingOut
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Icon(Icons.exit_to_app, size: iconSize),
            secondChild: SizedBox.fromSize(
              size: Size(iconSize, iconSize),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          label: Text(context.intl.settings.logoutButton.toUpperCase()),
        );
      },
    );
  }
}
