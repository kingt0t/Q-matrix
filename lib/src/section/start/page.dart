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
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app.dart';
import '../../matrix.dart';

import '../../resources/theme.dart';
import '../../resources/intl/localizations.dart';

import 'login/username/page.dart';

import '../main/widgets/pattle_logo.dart';

import 'bloc.dart';

class StartPage extends StatefulWidget {
  StartPage._();

  @override
  State<StatefulWidget> createState() => _StartPageState();

  static Widget withBloc() {
    return BlocProvider<StartBloc>(
      create: (context) => StartBloc(Matrix.of(context)),
      child: StartPage._(),
    );
  }
}

class _StartPageState extends State<StartPage> {
  bool _logoVisible = true;

  void _onLoginButtonPressed() {
    context.bloc<StartBloc>().add(ProgressToNextStep());
  }

  void _onUsernameLoginPageTransitionEnd() {
    setState(() {
      _logoVisible = false;
    });
  }

  void _goToMain() {
    Navigator.pushNamedAndRemoveUntil(context, Routes.chats, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: BlocConsumer<StartBloc, StartState>(
        listener: (context, state) {
          if (state is Finished) {
            _goToMain();
          }
        },
        builder: (context, state) {
          if (state is ErrorOccurred) {
            // TODO: Handle differently in 1.0
            return _ErrorPage(
              error: state.error,
              stackTrace: state.stackTrace,
            );
          }

          return Stack(
            children: <Widget>[
              if (_logoVisible)
                _LogoPage(
                  onLoginButtonPressed: _onLoginButtonPressed,
                ),
              if (state.currentStep == Step.loading) _LoadingPage(),
              UsernameLoginPage.withBloc(
                visible: state.currentStep == Step.login,
                onTransitionEnd: _onUsernameLoginPageTransitionEnd,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogoPage extends StatelessWidget {
  final VoidCallback onLoginButtonPressed;

  const _LogoPage({
    Key key,
    this.onLoginButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 64),
            PattleLogo(width: 256),
            SizedBox(height: 24),
            Text(
              context.intl.appName,
              style: TextStyle(
                fontFamily: creteRound,
                fontSize: 64,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 64,
                  ).copyWith(
                    bottom: 32,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(96),
                      ),
                      color: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: onLoginButtonPressed,
                      child: Text(
                        context.intl.start.login.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TEMPORARY: Will be animation
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PattleLogo(width: 256),
          SizedBox(height: 24),
          Text(
            'Loading',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final dynamic error;
  final StackTrace stackTrace;

  const _ErrorPage({
    Key key,
    @required this.error,
    this.stackTrace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 64,
        ),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.bug_report,
                      size: 32,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                          children: [
                            TextSpan(
                              text:
                                  '${context.intl.error.anErrorHasOccurred}\n',
                            ),
                            TextSpan(
                              text: error.toString(),
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (stackTrace != null && stackTrace != StackTrace.empty)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16).copyWith(top: 0),
                          child: Text(
                            stackTrace.toString(),
                            style: TextStyle(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
