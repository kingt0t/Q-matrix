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

import 'dart:io';
import 'dart:typed_data';

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

  Future<File> getThumbnailFile(String url, int width, int height) async {
    return getSingleFile(url + ':::' + width.toString() + 'x' + height.toString() + ':::');
  }

  static RegExp _thumbnailUrlRe = new RegExp(r"(.+):::(\d+)x(\d+):::");

  static Future<FileFetcherResponse> _fetch(
      String url, {Map<String, String> headers}) async {
    int width, height;

    final m = _thumbnailUrlRe.firstMatch(url);
    if (m != null) {
      width = int.parse(m.group(2));
      height = int.parse(m.group(3));
      url = m.group(1);
    }

    final uri = Uri.parse(url);

    var bytes;
    if (width != null && height != null) {
      bytes = await homeserver.downloadThumbnail(uri,
        width: width,
        height: height
      );
    } else {
      bytes = await homeserver.download(uri);
    }

    return MatrixFileFetcherResponse(bytes);
  }
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