import 'package:flutter/cupertino.dart';

class MessageChatScreenIOS extends StatefulWidget {
  Widget msgChatScreenBody;
  MessageChatScreenIOS({this.msgChatScreenBody});
  @override
  _MessageChatScreenIOSState createState() => _MessageChatScreenIOSState();
}

class _MessageChatScreenIOSState extends State<MessageChatScreenIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: widget.msgChatScreenBody,
    );
  }
}
