// Copyright (C) 2019  Wilko Manger
// Copyright (C) 2019  Mathieu Velten (FLA signed)
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

import '../../../../../../../resources/intl/localizations.dart';
import '../../../../../../../models/chat_message.dart';

import '../state.dart';

typedef SingleNameIntlContent = List<TextSpan> Function(
  Person person,
  String name, {
  TextStyle style,
});

typedef PersonForMessage = Person Function(ChatMessage message);
typedef NameForMessage = String Function(ChatMessage message);

/// If [message] is `null`, will try to get the [message] from the
/// ancestor [StateBubble]'s [StateBubble].
class StateContent extends StatelessWidget {
  static const highlightedStyle = TextStyle(fontWeight: FontWeight.bold);

  final List<TextSpan> spans;

  static Widget singleName({
    ChatMessage message,
    @required SingleNameIntlContent content,
    @required PersonForMessage person,
    @required NameForMessage name,
  }) {
    return Builder(
      builder: (context) {
        final msg = message ?? StateBubble.of(context).message;

        return StateContent(
          spans: content(
            person(msg),
            name(msg),
            style: highlightedStyle,
          ),
        );
      },
    );
  }

  const StateContent({
    Key key,
    this.spans,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: spans,
      ),
    );
  }
}
