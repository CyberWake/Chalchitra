import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/model/theme.dart';

class PlayerIOS extends StatefulWidget {
  Widget playerBody;
  VideoPlayerController controller;
  bool playing;
  PlayerIOS({this.playerBody, this.controller, this.playing});
  @override
  _PlayerIOSState createState() => _PlayerIOSState();
}

class _PlayerIOSState extends State<PlayerIOS> {
  GlobalKey floatingKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
        child: Stack(
      children: [
        widget.playerBody,
        MediaQuery.of(context).orientation == Orientation.portrait
            ? Positioned(
                right: 0.0,
                bottom: _size.width * 0.3,
                child: FloatingActionButton(
                  key: floatingKey,
                  backgroundColor: AppTheme.secondaryColor,
                  onPressed: () {
                    widget.playing
                        ? widget.controller.pause()
                        : widget.controller.play();
                    widget.playing = widget.controller.value.isPlaying;
                    setState(() {});
                  },
                  child: Icon(
                    widget.playing ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.pureBlackColor,
                  ),
                ),
              )
            : Container(),
      ],
    ));
  }
}
