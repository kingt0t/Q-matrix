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

/*class ErrorBanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ErrorBannerState();
}

class ErrorBannerState extends State<ErrorBanner>
    with SingleTickerProviderStateMixin<ErrorBanner> {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn))
          ..addListener(
            () {
              setState(() {});
            },
          );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<SyncState>(
        // TODO: Temporary
        stream: Matrix.of(context).user.sync,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final error = state?.exception ?? snapshot.error;

          if (error != null) {
            _controller.forward();
          } else {
            _controller.animateBack(0);
          }

          Widget icon, text;

          if (error is SocketException || error is http.ClientException) {
            icon = Icon(Icons.cloud_off);
            text = Text(context.intl.error.connectionLost);
          } else if (error is Response && error.statusCode == 504) {
            icon = Icon(Icons.cloud_off);
            text = Text(context.intl.error.connectionFailedServerOverloaded);
          } else {
            // TODO: Make error messages less complex for end users,
            // but keep it like this for now (before 1.0).
            icon = Icon(Icons.bug_report);
            text = RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${context.intl.error.anErrorHasOccurred}\n',
                  ),
                  TextSpan(
                    text: error.toString(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '\n${context.intl.error.thisErrorHasBeenReported}',
                  ),
                ],
              ),
            );
          }

          return SizeTransition(
            sizeFactor: _animation,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
              ),
              child: Material(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: icon,
                      ),
                      SizedBox(width: 16),
                      Flexible(child: text)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}*/
