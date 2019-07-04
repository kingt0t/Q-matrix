// Copyright (C) 2019  Wilko Manger
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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:pattle/src/ui/main/chat/image/image_bloc.dart';
import 'package:pattle/src/ui/util/date_format.dart';
import 'package:pattle/src/ui/util/user.dart';
import 'package:pattle/src/ui/util/matrix_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:pattle/src/di.dart' as di;

class ImagePageState extends State<ImagePage> {

  final me = di.getLocalUser();
  ImageBloc bloc;
  final ImageMessageEvent message;

  var _messageSender;
  var _date;

  ImagePageState(this.message) {
    bloc = ImageBloc(message);
    bloc.room = message.room;
  }

  @override
  void initState() {
    super.initState();
    bloc.startLoadingEvents();
    _messageSender = message.sender;
  }

  @override
  void didChangeDependencies() {
    _date =
      '${formatAsDate(context, message.time)}, ${formatAsTime(message.time)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          _buildPhotoViewList(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayNameOf(_messageSender)),
                  SizedBox(height: 2),
                  Text(
                    _date,
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.white,
                    )
                  ),
                ],
              ),
              backgroundColor: Color(0x64000000),
            ),
          )
        ]
      )
    );
  }

  Widget _buildPhotoViewList() {
    return StreamBuilder<List<ImageMessageEvent>>(
      stream: bloc.events,
      builder: (BuildContext context, AsyncSnapshot<List<ImageMessageEvent>> snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            final events = snapshot.data;
            return PhotoViewGallery.builder(
              itemCount: events.length,
              reverse: true,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: MatrixImage(events[index].content.url),
                  heroTag: message.id,
                  minScale: PhotoViewComputedScale.contained
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _messageSender = events[index].sender;
                  _date =
                    '${formatAsDate(context, events[index].time)}, ${formatAsTime(events[index].time)}';
                });
              },
              pageController: 
                  PageController(initialPage: events.indexOf(message))
            );
        }
      }
    );
  }
}

class ImagePage extends StatefulWidget {

  final ImageMessageEvent message;

  ImagePage(this.message);

  @override
  State<StatefulWidget> createState() => ImagePageState(message);
}
