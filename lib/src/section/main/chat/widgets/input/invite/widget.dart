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
import 'package:matrix_sdk/matrix_sdk.dart';

import '../../../../../../matrix.dart';

import 'bloc.dart';

class InviteInput extends StatelessWidget {
  final RoomId roomId;

  const InviteInput._({
    Key key,
    @required this.roomId,
  }) : super(key: key);

  static Widget withBloc({@required RoomId roomId}) {
    return BlocProvider<InviteInputBloc>(
      create: (c) => InviteInputBloc(Matrix.of(c), roomId),
      child: InviteInput._(roomId: roomId),
    );
  }

  void _accept(BuildContext context) {
    context.bloc<InviteInputBloc>().add(AcceptInvite());
  }

  void _reject(BuildContext context) {
    context.bloc<InviteInputBloc>().add(RejectInvite());
  }

  void _onStateChange(BuildContext context, InviteInputState state) {
    if (state is Rejected) {
      Navigator.pop(context);
    }
  }

  static const _linearProgressIndicatorHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InviteInputBloc, InviteInputState>(
      listener: _onStateChange,
      builder: (context, state) {
        // TODO: Use Material outside of widget when Input doesn't need specific
        // changes to it anymore
        final isLoading = state is Accepting || state is Rejecting;

        return Material(
          elevation: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.decelerate,
                switchOutCurve: Curves.decelerate,
                child: isLoading
                    ? LinearProgressIndicator()
                    : SizedBox(
                        height: _linearProgressIndicatorHeight,
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: !isLoading ? () => _reject(context) : null,
                    icon: Icon(Icons.clear),
                    label: Text('Reject'.toUpperCase()),
                  ),
                  FlatButton.icon(
                    onPressed: !isLoading ? () => _accept(context) : null,
                    icon: Icon(Icons.check),
                    label: Text('Accept'.toUpperCase()),
                  ),
                ],
              ),
              // For symmetry
              SizedBox(height: _linearProgressIndicatorHeight),
            ],
          ),
        );
      },
    );
  }
}
