import 'package:flutter/cupertino.dart';

class MessageScreenIOS extends StatefulWidget {
  Widget msgScreenBody;
  MessageScreenIOS({this.msgScreenBody});
  @override
  _MessageScreenIOSState createState() => _MessageScreenIOSState();
}

class _MessageScreenIOSState extends State<MessageScreenIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: widget.msgScreenBody);
  }
}
