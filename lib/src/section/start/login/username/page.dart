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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mdi/mdi.dart';

import '../../../../resources/intl/localizations.dart';

import 'widgets/text_field.dart';
import '../widgets/homeserver_text_field.dart';
import '../widgets/login_button.dart';

import '../../bloc.dart';
import '../../../../auth/bloc.dart';
import '../../../../settings/bloc.dart';
import '../../../../sentry/bloc.dart';

import '../bloc.dart';

class UsernameLoginPage extends StatefulWidget {
  final bool visible;
  final VoidCallback onVisibleTransitionEnd;

  const UsernameLoginPage._({
    Key key,
    this.visible = false,
    this.onVisibleTransitionEnd,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => UsernameLoginPageState();

  static Widget withBloc({
    Key key,
    bool visible = false,
    VoidCallback onTransitionEnd,
  }) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(
        context.bloc<StartBloc>(),
        context.bloc<AuthBloc>(),
        context.bloc<SentryBloc>(),
      ),
      child: UsernameLoginPage._(
        key: key,
        visible: visible,
        onVisibleTransitionEnd: onTransitionEnd,
      ),
    );
  }
}

class UsernameLoginPageState extends State<UsernameLoginPage>
    with
        TickerProviderStateMixin,
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  static const _duration = Duration(milliseconds: 200);
  static const _homeserverSectionHeight = 96.0;

  final _homeserverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _homeserverFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  AnimationController _visiblityController;
  bool _visible;
  bool _homeserverSectionVisible = false;

  /// Focus node of either username or password field.
  FocusNode _mainFocusNode;

  bool _showPassword = false;

  bool _showHomeserverSection = false;

  void _notifyPasswordChange() {
    context.bloc<LoginBloc>().add(PasswordChanged());
    setState(() {});
  }

  void _login() {
    BlocProvider.of<LoginBloc>(context).add(
      Login(
        password: _passwordController.text,
      ),
    );
  }

  void _toggleShowHomeserverSection() {
    var anyFocus = _homeserverFocusNode.hasFocus ||
        _usernameFocusNode.hasFocus ||
        _passwordFocusNode.hasFocus;

    setState(() {
      _showHomeserverSection = !_showHomeserverSection;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (anyFocus) {
        if (_showHomeserverSection) {
          _homeserverFocusNode.requestFocus();

          final inputLength = _homeserverController.text.length;
          _homeserverController.selection = TextSelection(
            baseOffset: inputLength,
            extentOffset: inputLength,
          );
        } else {
          _mainFocusNode.requestFocus();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _visible = widget.visible;

    _visiblityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _visiblityController.addListener(() {
      if (_visiblityController.status == AnimationStatus.forward) {
        setState(() {
          _visible = true;
        });
      } else if (_visiblityController.status == AnimationStatus.dismissed) {
        setState(() {
          _visible = false;
        });
      }

      if (_visiblityController.status == AnimationStatus.completed) {
        setState(() {
          _homeserverSectionVisible = true;
        });

        widget.onVisibleTransitionEnd?.call();
      }

      if (_visiblityController.status == AnimationStatus.reverse) {
        setState(() {
          _homeserverSectionVisible = false;
        });
      }
    });

    _visiblityController.value = _visible ? 1 : 0;

    _usernameFocusNode.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _mainFocusNode = _usernameFocusNode;
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _mainFocusNode = _passwordFocusNode;
      }
    });

    // Animate error report switch based on keyboard position
    WidgetsBinding.instance.addObserver(this);
  }

  double _bottomInset = 0;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    setState(() {
      _bottomInset = WidgetsBinding.instance.window.viewInsets.bottom /
          MediaQuery.of(context).devicePixelRatio;
    });
  }

  @override
  void didUpdateWidget(UsernameLoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.visible && widget.visible) {
      _visiblityController.forward();
    } else if (oldWidget.visible && !widget.visible) {
      _visiblityController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return Container();
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _visiblityController,
        curve: Curves.ease,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            AnimatedCrossFade(
              duration: _duration,
              crossFadeState: !_showHomeserverSection
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: IconButton(
                icon: Icon(Mdi.homeEdit),
                onPressed: _toggleShowHomeserverSection,
              ),
              secondChild: IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                onPressed: _toggleShowHomeserverSection,
              ),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Visibility(
              visible: _homeserverSectionVisible,
              child: SizedBox(
                width: double.infinity,
                height: _homeserverSectionHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: Theme.of(context).primaryColorDark,
                      ),
                      child: HomeserverTextField(
                        controller: _homeserverController,
                        focusNode: _homeserverFocusNode,
                        enabled: _showHomeserverSection,
                        onEditingComplete: _toggleShowHomeserverSection,
                      )),
                ),
              ),
            ),
            SlideTransition(
              position: CurvedAnimation(
                parent: _visiblityController,
                curve: Curves.ease,
              ).drive(
                Tween(
                  begin: Offset(0, 0.4),
                  end: Offset(0, 0),
                ),
              ),
              child: AnimatedPadding(
                duration: _duration,
                curve: Curves.ease,
                padding: EdgeInsets.only(
                  top: _showHomeserverSection ? _homeserverSectionHeight : 0,
                ),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: <Widget>[
                        UsernameTextField(
                          textEditingController: _usernameController,
                          focusNode: _usernameFocusNode,
                        ),
                        SizedBox(height: 8),
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            String errorText;

                            if (state is LoginFailed) {
                              errorText = context
                                  .intl.start.username.wrongPasswordError;
                            }

                            return TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              onChanged: (_) => _notifyPasswordChange(),
                              onEditingComplete: () {},
                              obscureText: !_showPassword,
                              enableInteractiveSelection: true,
                              decoration: InputDecoration(
                                labelText: context.intl.common.password,
                                errorText: errorText,
                                // Needed so that an error does
                                // not make the layout jump
                                helperText: '',
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<LoginBloc, LoginState>(
                          condition: (previousState, currentState) {
                            final newStateIsNowNotLoggedIn =
                                previousState is! NotLoggedIn &&
                                    currentState is NotLoggedIn;

                            final canLoginChanged = previousState
                                    is NotLoggedIn &&
                                currentState is NotLoggedIn &&
                                previousState.canLogin != currentState.canLogin;

                            final notLoginSuccessful =
                                currentState is! LoginSuccessful;

                            return newStateIsNowNotLoggedIn ||
                                canLoginChanged ||
                                notLoginSuccessful;
                          },
                          builder: (context, state) {
                            // Only enable the button if the input is valid
                            final login = state is NotLoggedIn &&
                                    state.canLogin &&
                                    _passwordController.text.isNotEmpty
                                ? _login
                                : null;

                            return LoginButton(
                              loading: state is LoggingIn,
                              onPressed: login,
                              child: Text(
                                context.intl.start.login.toUpperCase(),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: AnimatedPadding(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.decelerate,
                            padding: EdgeInsets.only(bottom: _bottomInset),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: BlocBuilder<SettingsBloc, SettingsState>(
                                builder: (context, state) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.only(left: 16),
                                    title: Text('Send error reports'),
                                    trailing: Switch.adaptive(
                                      value: state.sendErrorReports,
                                      onChanged: (value) =>
                                          context.bloc<SettingsBloc>().add(
                                                UpdateSendErrorReports(value),
                                              ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
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

  @override
  void dispose() {
    _visiblityController.dispose();
    super.dispose();
  }
}
