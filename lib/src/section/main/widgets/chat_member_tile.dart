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

import '../../../resources/theme.dart';
import '../../../models/chat_member.dart';

import '../../../util/chat_member.dart';

import 'chat_member_avatar.dart';

class ChatMemberTile extends StatefulWidget {
  final ChatMember member;
  final bool checkable;
  final bool checked;

  final VoidCallback onSelected;
  final VoidCallback onUnselected;

  const ChatMemberTile({
    Key key,
    @required this.member,
    this.checkable = false,
    this.checked = false,
    this.onSelected,
    this.onUnselected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatMemberTileState();
}

class ChatMemberTileState extends State<ChatMemberTile> {
  bool checked;

  @override
  void initState() {
    super.initState();
    checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 42.0;

    Widget avatar = ChatMemberAvatar(
      member: widget.member,
      radius: avatarSize * 0.5,
    );

    // TODO: Add checkmark animation
    if (widget.checkable && checked) {
      avatar = Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          avatar,
          SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Align(
              alignment: Alignment(1.5, 1.5),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Icon(
                    Icons.check_circle,
                    color: context.pattleTheme.data.primaryColor,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(
        widget.member.nameOrYou(context),
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: widget.checkable
          ? () {
              setState(() {
                checked = !checked;

                if (checked) {
                  widget.onSelected();
                } else {
                  widget.onUnselected();
                }
              });
            }
          : null,
    );
  }
}
