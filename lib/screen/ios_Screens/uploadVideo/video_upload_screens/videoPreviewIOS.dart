import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoPreviewIOS extends StatefulWidget {
  Widget previewBody;
  Widget previewBottomNav;

  VideoPreviewIOS({this.previewBottomNav,this.previewBody});
  @override
  _VideoPreviewIOSState createState() => _VideoPreviewIOSState();
}

class _VideoPreviewIOSState extends State<VideoPreviewIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.black,
        navigationBar: CupertinoNavigationBar(
          middle: Text("Video Preview"),
        ),
        child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              widget.previewBody,
              widget.previewBottomNav,
            ])
    );
  }
}
