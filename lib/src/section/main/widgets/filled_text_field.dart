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
class FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;

  final Color fillColor;

  final bool autofocus;

  final String prefixText;
  final Widget prefix;
  final Widget prefixIcon;
  final String hintText;
  final String helperText;
  final Widget suffixIcon;

  const FilledTextField({
    Key key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization,
    this.textInputAction,
    this.fillColor,
    this.autofocus = false,
    this.prefixText,
    this.prefix,
    this.prefixIcon,
    this.hintText,
    this.helperText,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget withIconTheme(Widget child) {
      if (child == null) {
        return null;
      }

      return IconTheme(
        data: IconThemeData(color: Colors.white),
        child: child,
      );
    }

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autocorrect: false,
      autofocus: autofocus,
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
      ),
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.zero,
        ),
        fillColor: fillColor ?? context.pattleTheme.data.primaryColor,
        focusColor: Colors.white,
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Colors.white),
        prefix: prefix,
        prefixIcon: withIconTheme(prefixIcon),
        hintText: hintText,
        hintStyle: TextStyle(color: context.pattleTheme.data.primaryColorLight),
        suffixIcon: withIconTheme(suffixIcon),
      ),
    );
  }
}
