# Pattle

  [![](https://img.shields.io/matrix/app:pattle.im.svg?server_fqdn=matrix.org)](https://matrix.to/#/#app:pattle.im)
  
  ![Preview](/CHANGELOG/0.5.0.png)

  Pattle is an easy to use Android app for Matrix, with
  design inspired by other popular IM apps.

  The goal of Pattle is to create an app that behaves similiary
  (and almost exactly) like many modern popular chat apps of today,
  like WhatsApp, Telegram and Signal. This is not the only goal,
  however: the primary goal of Pattle is to be a Matrix app that
  everyone can use, in terms of simplicity.

  For more details, see the
  [design philosophy](https://docs.pattle.im/design/philosophy/).

## Get Pattle
  
  Pattle supports Android (from 4.1 and up) and iOS (from 8.0 and up), and in the
  future Pattle will also be available on desktop and the web.

### Android

  Pattle is available on [F-droid](https://f-droid.org/en/packages/im.pattle.app/)
  and [Google Play](https://play.google.com/store/apps/details?id=im.pattle.app)!

### iOS

  Pattle is available on TestFlight!
  [Follow the instructions here to install.](https://testflight.apple.com/join/uTytydST)
  
  Later on Pattle will be available in the App Store.

## Contributing

  Contributions are encouraged! See [CONTRIBUTING](CONTRIBUTING.md) for
  details on how to contribute!

  For many features, contributions might also be needed for the
  [Matrix Dart SDK](https://git.pattle.im/pattle/library/matrix-dart-sdk),
  which is developed for Pattle.

## Building

  Pattle is made with [Flutter](https://flutter.dev/). To build Pattle,
  you'll need the [Flutter SDK](https://flutter.dev/docs/get-started/install).

  Before building a debug build, make sure you have a `.env` file in the
  root of the project. You can just `cp .env.example .env`, because
  Sentry is not used in debug mode.

  Since Pattle uses the beta branch of the Flutter, make sure to
  switch to this branch by running `flutter channel beta`. Then,
  run `flutter upgrade`.

  After the Flutter SDK is setup and ready, you can build Pattle with:
  `flutter build apk` for Android, or
  `flutter build ios` for iOS.
