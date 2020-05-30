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

import 'bloc.dart';

class Version extends StatefulWidget {
  Version._({Key key});

  static Widget withBloc() {
    return BlocProvider<VersionBloc>(
      create: (context) => VersionBloc(),
      child: Version._(),
    );
  }

  @override
  State<StatefulWidget> createState() => _VersionState();
}

class _VersionState extends State<Version> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.bloc<VersionBloc>().add(GetVersion());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionBloc, VersionState>(
      builder: (context, state) {
        if (state.version != null) {
          return Text(context.intl.settings.version(state.version));
        } else {
          return Container();
        }
      },
    );
  }
}
