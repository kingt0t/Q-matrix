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

import 'dart:typed_data';

import 'package:pattle/src/di.dart' as di;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url/url.dart';

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

  static Future<FileFetcherResponse> _fetch(
    String url, {Map<String, String> headers}) async {

    final parsedUrl = Url.parse(url);
    int width, height;

    try {
      width = int.parse(headers['width']);
      height = int.parse(headers['height']);
    } on FormatException { }

    Stream<List<int>> stream;
    if (width != null && height != null) {
      stream = await homeserver.downloadThumbnail(
        parsedUrl,
        width: width,
        height: height
      );
    } else {
      stream = await homeserver.download(parsedUrl);
    }

    return MatrixFileFetcherResponse(await consumeStream(stream));
  }
}

// TODO implements streams in cache manager to avoid that
Future<Uint8List> consumeStream(Stream<List<int>> stream) async {
  final bytes = List<int>();
  await stream.forEach((d) {
    bytes.addAll(d);
  });
  return Uint8List.fromList(bytes);
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