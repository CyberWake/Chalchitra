import 'package:flutter/cupertino.dart';

class PlayerIOS extends StatefulWidget {
  Widget playerBody;
  PlayerIOS({this.playerBody});
  @override
  _PlayerIOSState createState() => _PlayerIOSState();
}

class _PlayerIOSState extends State<PlayerIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: widget.playerBody );
  }
}
