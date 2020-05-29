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

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../../chat_order/bloc.dart';
import '../../../../../../../matrix.dart';
import '../../../../../widgets/avatar.dart';

import '../../../../../../../resources/theme.dart';

import 'bloc.dart';
import '../../models/channel.dart';

typedef ChannelDetailsPageBuilder = Widget Function(BuildContext, Channel);

class ChannelList extends StatefulWidget {
  final String searchTerm;
  final ChannelDetailsPageBuilder channelDetailsPageBuilder;

  ChannelList._(this.searchTerm, this.channelDetailsPageBuilder);

  static Widget withBloc({
    String searchTerm,
    ChannelDetailsPageBuilder channelDetailsPageBuilder,
  }) {
    return BlocProvider<ChannelListBloc>(
      create: (context) => ChannelListBloc(
        Matrix.of(context),
        context.bloc<ChatOrderBloc>(),
      ),
      child: ChannelList._(searchTerm, channelDetailsPageBuilder),
    );
  }

  @override
  State<StatefulWidget> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final _scrollController = ScrollController();

  bool _requesting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bloc = context.bloc<ChannelListBloc>();

    bloc.add(GetChannels(widget.searchTerm));

    _scrollController.addListener(() {
      if (!_requesting &&
          _scrollController.position.maxScrollExtent -
                  _scrollController.position.pixels <=
              700) {
        _requesting = true;
        bloc.add(GetChannels(widget.searchTerm));
      }
    });
  }

  void _onStateChange(BuildContext context, ChannelListState state) {
    _requesting = false;
  }

  @override
  void didUpdateWidget(ChannelList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchTerm != widget.searchTerm) {
      context.bloc<ChannelListBloc>().add(GetChannels(widget.searchTerm));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChannelListBloc, ChannelListState>(
      listener: _onStateChange,
      builder: (context, state) {
        Widget child;
        final allChannels =
            (state.myChannels ?? []) + (state.extraChannels ?? []);

        if (allChannels.isNotEmpty) {
          final hasExtraChannels = state.extraChannels?.isNotEmpty == true;

          child = ListView.builder(
            controller: _scrollController,
            itemCount: hasExtraChannels
                ? allChannels.length + 1 // +1 for the matrix.org header
                : allChannels.length,
            itemBuilder: (context, index) {
              final myChannels = state.myChannels;
              final matrixChannels = state.extraChannels;

              if (index == myChannels.length) {
                return _ChannelServerHeader();
              }

              final channel = index < myChannels.length
                  ? myChannels[index]
                  : matrixChannels[index - myChannels.length - 1];

              return OpenContainer(
                closedElevation: 0,
                tappable: false,
                closedColor: Theme.of(context).scaffoldBackgroundColor,
                closedShape: ContinuousRectangleBorder(),
                closedBuilder: (context, void Function() action) {
                  return _ChannelTile(
                    channel: channel,
                    onTap: action,
                  );
                },
                // ASSUMPTION
                openColor: context.pattleTheme.data.chat.backgroundColor,
                openBuilder: (context, _) => widget.channelDetailsPageBuilder(
                  context,
                  channel,
                ),
              );
            },
          );
        } else {
          child = Center(
            child: CircularProgressIndicator(),
          );
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.decelerate,
          switchOutCurve: Curves.decelerate.flipped,
          child: child,
        );
      },
    );
  }
}

class _ChannelServerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 80,
        top: 16,
        bottom: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(height: 1),
          SizedBox(height: 6),
          Text(
            'matrix.org',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const _ChannelTile({
    Key key,
    @required this.channel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Avatar.channel(url: channel.avatarUrl),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              channel.name ?? channel.alias ?? 'Channel',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            NumberFormat.compact().format(channel.memberCount),
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(width: 4),
          Icon(
            Icons.group,
            size: 16,
            color: Theme.of(context).textTheme.caption.color,
          ),
        ],
      ),
      subtitle: Text(
        channel.topic ?? channel.alias ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
