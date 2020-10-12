import 'package:flutter/cupertino.dart';

class CommentsIOS extends StatefulWidget {
  Widget commentsBody;
  CommentsIOS({this.commentsBody});
  @override
  _CommentsIOSState createState() => _CommentsIOSState();
}

class _CommentsIOSState extends State<CommentsIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: widget.commentsBody,
    );
  }
}
