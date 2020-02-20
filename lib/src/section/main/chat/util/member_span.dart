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

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/resources/localizations.dart';

import '../../../../util/user.dart';

List<TextSpan> spanFor(
  BuildContext context,
  MemberChangeEvent event, {
  TextStyle style = const TextStyle(fontWeight: FontWeight.bold),
}) {
  final sender = TextSpan(
    text: event.sender.displayName,
    style: style,
  );
  final subject = TextSpan(
    text: event.subject.displayName,
    style: style,
  );
  var text;

  if (event is DisplayNameChangeEvent) {
    final oldName = TextSpan(
      text: event.subject.nameOrDisplayId(name: event.oldSubjectName),
      style: style,
    );

    final newName = TextSpan(
      text: event.subject.displayName,
      style: style,
    );

    text = l(context).changedTheirNameTo(oldName, newName);
  } else if (event is JoinEvent) {
    text = l(context).joined(subject);
  } else if (event is LeaveEvent) {
    text = l(context).left(subject);
  } else if (event is InviteEvent) {
    text = l(context).wasInvitedBy(subject, sender);
  } else if (event is BanEvent) {
    text = l(context).wasBannedBy(subject, sender);
  }

  return text;
}
