// Copyright (C) 2019  Wilko Manger
// Copyright (C) 2019  Mathieu Velten
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
import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:pattle/src/di.dart' as di;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final cacheManager = MatrixCacheManager();

class MatrixCacheManager extends BaseCacheManager {

  static const key = 'matrix';

  static final homeserver = di.getHomeserver();

  MatrixCacheManager() : super(key, fileFetcher: _fetch);

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }

  // We precompute the round thumbnail because we can't do it at runtime with a widget for notifs
  Future<File> getThumbnailFile(String url, {bool round = true, int width, int height}) async {
    // Use the default size of medium quality thumbnails in synapse
    width = width == null ? 320 : width;
    height = height == null ? 240 : height;
    final roundStr = round ? ':round' : '';
    return getSingleFile('thumbnail:${width}x$height$roundStr:$url');
  }

  static RegExp _thumbnailUrlRe = new RegExp(r'thumbnail:(\d+)x(\d+)(:round)*:(.*)');

  static Future<FileFetcherResponse> _fetch(
      String url, {Map<String, String> headers}) async {
    int width, height;
    bool round = false;

    final m = _thumbnailUrlRe.firstMatch(url);
    if (m != null) {
      width = int.parse(m.group(1));
      height = int.parse(m.group(2));
      round = m.group(3) != null;
      url = m.group(4);
    }

    final uri = Uri.parse(url);

    var bytes;
    if (width != null && height != null) {
      bytes = await homeserver.downloadThumbnail(uri,
        width: width,
        height: height
      );

      if (round) {
        bytes = await createRoundThumbnail(bytes);
      }
    } else {
      bytes = await homeserver.download(uri);
    }

    return MatrixFileFetcherResponse(bytes);
  }
}

final _transparentColor = Color.fromRgba(255, 255, 255, 0);

// This create a cropped round transparent PNG at max res
Future<List<int>> createRoundThumbnail(List<int> bytes) async {
  final image = decodeImage(bytes);

  final size = image.width < image.height ? image.width: image.height;

  final radius = (size / 2).floor();

  final x0 = ((image.width - size) / 2).floor();
  final y0 = ((image.height - size) / 2).floor();

  final newImage = Image(size, size);

  for(int y=0; y<size; y++) {
    for(int x=0; x<size; x++) {
      if((x-radius)*(x-radius)+(y-radius)*(y-radius) > radius*radius) {
        newImage[y * size + x] = _transparentColor;
      } else {
        final xOrig = x0 + x;
        final yOrig = y0 + y;
        newImage[y * size + x] = image[yOrig * image.width + xOrig];
      }
    }
  }

  return encodePng(newImage);
}

class MatrixFileFetcherResponse implements FileFetcherResponse {
  @override
  final Uint8List bodyBytes;

  MatrixFileFetcherResponse(this.bodyBytes);

  @override
  bool hasHeader(String name) => false;

  @override
  String header(String name) => null;

  @override
  get statusCode => 200;
}