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
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/chat/util/member_span.dart';
import 'package:pattle/src/ui/main/models/chat_item.dart';

import 'state_bubble.dart';

class MemberBubble extends StateBubble {
  @override
  final MemberChangeEvent event;

  MemberBubble({
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
  State<StatefulWidget> createState() => MemberBubbleState();
}

class MemberBubbleState extends StateBubbleState<MemberBubble> {
  @override
  @protected
  List<TextSpan> buildContentSpans(BuildContext context) =>
      spanFor(context, widget.event, style: defaultEmphasisTextStyle);
}
