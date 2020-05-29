# Pattle

  [![](https://img.shields.io/matrix/app:pattle.im.svg?server_fqdn=matrix.org)](https://matrix.to/#/#app:pattle.im)
  
  ![Preview](/CHANGELOG/0.15.0.png)

  Pattle is an easy to use Android app for Matrix, with
  design inspired by other popular IM apps.

  The goal of Pattle is to create an app that behaves similarly
  like many modern popular chat apps of today, such as WhatsApp,
  Telegram and Signal. This is not the only goal, however:
  the primary goal of Pattle is to be a Matrix app that
  everyone can use, in terms of simplicity.

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

## Building

  Pattle is made with [Flutter](https://flutter.dev/). To build Pattle,
  you'll need the [Flutter SDK](https://flutter.dev/docs/get-started/install).

  Before building a debug build, make sure you have a `.env` file in the
  root of the project. You can just `cp .env.example .env`, because
  Sentry is not used in debug mode.

  After the Flutter SDK is setup and ready, you can build Pattle with:
  `flutter build apk` for Android, or
  `flutter build ios` for iOS.

## Contributing

   Contributions are encouraged!

   We use the [DCO](https://developercertificate.org/), which asserts that the
   contribution is yours, and you allow Pattle to use it.

   If you agree to what's stated in the DCO (also shown under), you can
   sign-off your commits:

   ```
   Signed-off-by: Joe Smith <joe.smith@email.org>
   ```

   If your `user.name` and `user.email` are set for git, you can
   sign-off your commits using:

   ```
   git commit -s
   ```

   Contributions can only be accepted if you agree to the DCO,
   indicated by the sign-off.

   See [CONTRIBUTING.md](CONTRIBUTING.md) for details on contributing.

### DCO

   ```text
   Developer Certificate of Origin
   Version 1.1

   Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
   660 York Street, Suite 102,
   San Francisco, CA 94110 USA

   Everyone is permitted to copy and distribute verbatim copies of this
   license document, but changing it is not allowed.

   Developer's Certificate of Origin 1.1

   By making a contribution to this project, I certify that:

   (a) The contribution was created in whole or in part by me and I
       have the right to submit it under the open source license
       indicated in the file; or

   (b) The contribution is based upon previous work that, to the best
       of my knowledge, is covered under an appropriate open source
       license and I have the right under that license to submit that
       work with modifications, whether created in whole or in part
       by me, under the same open source license (unless I am
       permitted to submit under a different license), as indicated
       in the file; or

   (c) The contribution was provided directly to me by some other
       person who certified (a), (b) or (c) and I have not modified
       it.

   (d) I understand and agree that this project and the contribution
       are public and that a record of the contribution (including all
       personal information I submit with it, including my sign-off) is
       maintained indefinitely and may be redistributed consistent with
       this project or the open source license(s) involved.
   ```
