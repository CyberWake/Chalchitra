import 'package:flutter/cupertino.dart';
import 'package:Chalchitra/imports.dart';

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
      backgroundColor: AppTheme.primaryColor,
      child: widget.selectorBody,
    );
  }
}
