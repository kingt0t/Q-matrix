// Copyright (C) 2020  Wilko Manger
// Copyright (C) 2019  Nathan van Beelen (CLA signed)
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
import 'package:matrix_sdk/matrix_sdk.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../models/chat_message.dart';

import '../../../../matrix.dart';

import '../../../../util/date_format.dart';
import '../util/image_provider.dart';

import 'bloc.dart';

class ImagePage extends StatefulWidget {
  final EventId eventId;

  ImagePage._(this.eventId);

  static Widget withBloc(RoomId roomId, EventId eventId) {
    return BlocProvider<ImageBloc>(
      create: (c) => ImageBloc(Matrix.of(c), roomId),
      child: ImagePage._(eventId),
    );
  }

  @override
  State<StatefulWidget> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  ChatMessage _initial;
  ChatMessage _current;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final messages = BlocProvider.of<ImageBloc>(context).state.messages;

    _initial = messages.firstWhere((msg) => msg.event.id == widget.eventId);
    _current = _initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_current.sender.name),
            SizedBox(height: 2),
            Text(
              '${formatAsDate(context, _current.event.time)},'
              ' ${formatAsTime(_current.event.time)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0x64000000),
      ),
      body: BlocBuilder<ImageBloc, ImageState>(builder: (context, state) {
        final messages = state.messages;

        return PhotoViewGallery.builder(
          itemCount: messages.length,
          reverse: true,
          builder: (context, index) {
            final event = messages[index].event as ImageMessageEvent;

            return PhotoViewGalleryPageOptions(
              imageProvider: imageProvider(
                context: context,
                url: event.content.url,
              ),
              minScale: PhotoViewComputedScale.contained,
            );
          },
          onPageChanged: (index) {
            setState(() {
              _current = messages[index];
            });
          },
          pageController: PageController(
            initialPage: messages.indexOf(_current),
          ),
        );
      }),
    );
  }
}
