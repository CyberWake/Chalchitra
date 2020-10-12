import 'package:flutter/cupertino.dart';

class VideoSelectorIOS extends StatefulWidget {
  Widget selectorBody;
  VideoSelectorIOS({this.selectorBody});
  @override
  _VideoSelectorIOSState createState() => _VideoSelectorIOSState();
}

class _VideoSelectorIOSState extends State<VideoSelectorIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: widget.selectorBody,
    );
  }
}
