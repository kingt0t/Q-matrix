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
import 'package:future_or_builder/future_or_builder.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/models/chat_item.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/util/user.dart';

import 'state_bubble.dart';

class CreationBubble extends StateBubble {
  @override
  final RoomCreationEvent event;

  CreationBubble({
    @required ChatEvent item,
    @required ChatItem previousItem,
    @required ChatItem nextItem,
    @required bool isMine,
  })  : event = item.event,
        super(
          item: item,
          previousItem: previousItem,
          nextItem: nextItem,
          isMine: isMine,
        );

  @override
  State<StatefulWidget> createState() => CreationBubbleState();
}

class CreationBubbleState extends StateBubbleState<CreationBubble> {
  @protected
  Widget buildContent(BuildContext context) {
    return FutureOrBuilder<User>(
      futureOr: widget.item.room.creator,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        return super.buildContent(context);
      },
    );
  }

  @protected
  @override
  List<TextSpan> buildContentSpans(BuildContext context) =>
      l(context).createdThisGroup(
        TextSpan(
          text: displayNameOf(widget.item.room.creator),
          style: defaultEmphasisTextStyle,
        ),
      );
}
