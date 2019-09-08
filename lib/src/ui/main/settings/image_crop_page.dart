// Copyright (C) 2019  Nathan van Beelen
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
import 'dart:io';
import 'dart:core';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pattle/src/ui/resources/localizations.dart';
import 'package:pattle/src/ui/resources/theme.dart';

import 'package:pattle/src/ui/main/settings/widgets/header.dart';

class ImageCropPageState extends State<ImageCropPage> {
  final cropKey = GlobalKey<CropState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height 
        - MediaQuery.of(context).padding.bottom
        - MediaQuery.of(context).padding.top
        - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).appearance),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _cropImage(),
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Crop.file(
          widget.image,
          key: cropKey,
          aspectRatio: screenWidth / screenHeight,
        )
      ),
    );
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;

    final croppedImage = await ImageCrop.cropImage(
      file: widget.image,
      area: area,
    );

    Navigator.pop(context);
  }
}

class ImageCropPage extends StatefulWidget {
  final File image;

  ImageCropPage({Key key, @required this.image}): super(key: key);

  @override
  State<StatefulWidget> createState() => ImageCropPageState();
}
