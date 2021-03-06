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

import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:matrix_sdk/matrix_sdk.dart' as matrix;
import 'package:sentry/sentry.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;

class Sentry {
  SentryClient _client;

  Sentry();

  static Future<Sentry> create() async {
    final sentry = Sentry();

    final client = SentryClient(
      dsn: DotEnv().env['SENTRY_DSN'],
      environmentAttributes: await sentry._environment,
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      if (sentry._isInDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        // Report to zone
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };

    sentry._client = client;

    return sentry;
  }

  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');
    if (_isInDebugMode) {
      if (error is Response) {
        print('statusCode: ${error.statusCode}');
        print('headers: ${error.headers}');
        print('body: ${error.body}');
      } else if (error is matrix.MatrixException) {
        print('body: ${error.body}');
      }

      if (stackTrace != null) {
        print(stackTrace);
      }
    } else {
      if (error is Response) {
        var body;
        try {
          body = json.decode(error.body);
        } on FormatException {
          body = error.body?.toString();
        }

        await _client.capture(
          event: Event(
            exception: error,
            stackTrace: stackTrace,
            extra: {
              'status_code': error.statusCode,
              'headers': error.headers,
              'body': body,
            },
          ),
        );
      } else if (error is matrix.MatrixException) {
        await _client.capture(
          event: Event(
            exception: error,
            stackTrace: stackTrace,
            extra: {
              'body': error.body,
            },
          ),
        );
      } else {
        await _client.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  bool get _isInDebugMode {
    bool inDebugMode = false;

    // Set to true if running debug mode (where asserts are evaluated)
    assert(inDebugMode = true);

    return inDebugMode;
  }

  Future<Event> get _environment async {
    final deviceInfo = DeviceInfoPlugin();

    User user;
    OperatingSystem os;
    Device device;

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;

      user = User(id: info.androidId);

      os = OperatingSystem(
        name: 'Android',
        version: info.version.release,
        build: info.version.sdkInt.toString(),
      );

      device = Device(
        model: info.model,
        manufacturer: info.manufacturer,
        brand: info.brand,
        simulator: !info.isPhysicalDevice,
      );
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;

      user = User(id: info.identifierForVendor);

      os = OperatingSystem(
        name: 'iOS',
        version: info.systemVersion,
      );

      device = Device(
        family: info.model,
        model: info.utsname.machine,
        simulator: !info.isPhysicalDevice,
      );
    }

    final packageInfo = await PackageInfo.fromPlatform();

    return Event(
      release: packageInfo.version,
      userContext: user,
      environment: 'production',
      contexts: Contexts(
        device: device,
        operatingSystem: os,
        app: App(
          build: packageInfo.buildNumber,
          buildType: DotEnv().env['BUILD_TYPE'],
        ),
      ),
    );
  }
}
