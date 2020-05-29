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

import '../../../resources/theme.dart';

/// Is the reverse brightness of the current theme's brightness.
class ReverseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> actions;

  const ReverseAppBar({
    Key key,
    this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextStyle = theme.appBarTheme.textTheme?.headline6 ??
        theme.primaryTextTheme.headline6;

    return AppBar(
      title: DefaultTextStyle(
        style: baseTextStyle.copyWith(
          color: context.pattleTheme.data.primaryColorOnBackground,
        ),
        child: title,
      ),
      brightness: Theme.of(context).brightness,
      iconTheme: IconThemeData(
        color: context.pattleTheme.data.primaryColorOnBackground,
      ),
      actions: actions,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
