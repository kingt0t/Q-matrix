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

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

// TODO: Purpose slowly broadens to more than chat ordering, rename?
class ChatOrderBloc extends Bloc<ChatOrderEvent, ChatOrderState> {
  static const _personalKey = 'personal';
  static const _publicKey = 'public';

  final SharedPreferences _preferences;

  ChatOrderBloc(this._preferences);

  @override
  ChatOrderState get initialState => _getFromPreferences();

  @override
  Stream<ChatOrderState> mapEventToState(ChatOrderEvent event) async* {
    if (event is UpdateChatOrder) {
      Map<RoomId, SortData> set(List<Chat> chats, String key) {
        var map = chats.toSortData();

        final current = key == _personalKey ? state.personal : state.public;

        map = {
          ...current,
          ...map,
        }.sorted;

        _preferences.setString(
          key,
          json.encode(
            map.map(
              (key, value) => MapEntry(
                key.toString(),
                value.toJson(),
              ),
            ),
          ),
        );

        return map;
      }

      yield ChatOrderState(
        personal: set(event.personal, _personalKey),
        public: set(event.public, _publicKey),
      );
    }
  }

  ChatOrderState _getFromPreferences() {
    Map<RoomId, SortData> get(String key) {
      final encoded = _preferences.getString(key);

      if (encoded == null) {
        return {};
      }

      final decoded = json.decode(encoded) as Map<String, dynamic>;

      return decoded.map(
        (key, value) => MapEntry(
          RoomId(key),
          SortData.fromJson(value),
        ),
      );
    }

    return ChatOrderState(
      personal: get(_personalKey),
      public: get(_publicKey),
    );
  }
}

@immutable
class SortData {
  final int highlightedNotificationCount;
  final int totalNotificationCount;
  final DateTime latestMessageTime;
  final Membership membership;

  SortData({
    @required this.highlightedNotificationCount,
    @required this.totalNotificationCount,
    @required this.latestMessageTime,
    @required this.membership,
  });

  static const _highlightedNotificationCountKey =
      'highlighted_notification_count';
  static const _totalNotificationCountKey = 'total_notification_count';
  static const _latestMessageTimeKey = 'latest_message_time';
  static const _membershipKey = 'membership';

  factory SortData.fromJson(Map<String, dynamic> json) {
    return SortData(
      highlightedNotificationCount: json[_highlightedNotificationCountKey],
      totalNotificationCount: json[_totalNotificationCountKey],
      latestMessageTime: json[_latestMessageTimeKey] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json[_latestMessageTimeKey],
            )
          : null,
      membership: Membership.parse(json[_membershipKey]),
    );
  }

  Map<String, dynamic> toJson() => {
        _highlightedNotificationCountKey: highlightedNotificationCount,
        _totalNotificationCountKey: totalNotificationCount,
        _latestMessageTimeKey: latestMessageTime?.millisecondsSinceEpoch,
        _membershipKey: membership.toString(),
      };
}

extension on List<Chat> {
  Map<RoomId, SortData> toSortData() {
    return Map.fromEntries(
      map(
        (c) => MapEntry(
          c.room.id,
          SortData(
            highlightedNotificationCount:
                c.room.highlightedUnreadNotificationCount,
            totalNotificationCount: c.room.totalUnreadNotificationCount,
            latestMessageTime: c.latestMessageForSorting?.event?.time,
            membership: c.room.me.membership,
          ),
        ),
      ),
    );
  }
}

extension on Map<RoomId, SortData> {
  Map<RoomId, SortData> get sorted {
    final entries = this.entries.toList();

    entries.sort((a, b) {
      final aSortData = a.value;
      final bSortData = b.value;

      if (aSortData.membership is! Invited &&
          bSortData.membership is! Invited) {
        final aHighlightedNotificationCount =
            aSortData.highlightedNotificationCount;
        final bHighlightedNotificationCount =
            bSortData.highlightedNotificationCount;

        final aTotalNotificationCount = aSortData.totalNotificationCount;
        final bTotalNotificationCount = bSortData.totalNotificationCount;

        if (aHighlightedNotificationCount > 0 &&
            bHighlightedNotificationCount <= 0) {
          return -1;
        } else if (aHighlightedNotificationCount <= 0 &&
            bHighlightedNotificationCount > 0) {
          return 1;
        } else if (aTotalNotificationCount > 0 &&
            bTotalNotificationCount <= 0) {
          return -1;
        } else if (aTotalNotificationCount <= 0 &&
            bTotalNotificationCount > 0) {
          return 1;
        }

        final aTime = aSortData.latestMessageTime;
        final bTime = bSortData.latestMessageTime;

        if (aTime != null && bTime != null) {
          return -aTime.compareTo(bTime);
        } else if (aTime != null && bTime == null) {
          return -1;
        } else if (aTime == null && bTime != null) {
          return 1;
        } else {
          return 0;
        }
      } else if (aSortData.membership is Invited &&
          bSortData.membership is! Invited) {
        return -1;
      } else if (aSortData.membership is! Invited &&
          bSortData.membership is Invited) {
        return 1;
      } else {
        return 0;
      }
    });

    return Map.fromEntries(entries);
  }
}
