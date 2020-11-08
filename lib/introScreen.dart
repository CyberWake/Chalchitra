import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class OnBoardScreen1 extends StatefulWidget {
  @override
  _OnBoardScreen1State createState() => _OnBoardScreen1State();
}

class _OnBoardScreen1State extends State<OnBoardScreen1> {
  VideoPlayerController _controller;
  Future<void> initialisedVideoPlayer;
  List<String> textList = [
    "90 seconds to Fame!",
    "It's your time to Shine!",
    "Rehearse. Record. Rise."
  ];
  int index = 0;
  String text = "90 seconds to Fame!";
  bool _visible = false;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    /*assets/videos/video1.mp4*/
    _controller = VideoPlayerController.asset('assets/videos/video1.mp4');
    print('${_controller.dataSource}');
    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
    _controller.setLooping(true);
    setState(() {
      _visible = true;
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
      _controller = null;
    }
    super.dispose();
  }

  _getVideoBackground() {
    print('running');
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: VideoPlayer(_controller),
    );
  }

  _getBackgroundColor() {
    return Container(
      color: Colors.black,
    );
  }

  _getContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 40.0),
          alignment: Alignment.center,
          child: Text(
            textList[index],
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.backgroundColor,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width / 8,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
          width: MediaQuery.of(context).size.width / 2,
          child: FlatButton(
            color: AppTheme.secondaryColor,
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 20, color: AppTheme.primaryColor),
            ),
            onPressed: () {
              _controller.pause();
              setState(() {});
              if (index == 0) {
                index += 1;
                text = textList[index];
                _controller =
                    VideoPlayerController.asset("assets/videos/video2.mp4");
                initialisedVideoPlayer = _controller.initialize();
                _visible = true;
                _controller.play();
                _controller.setLooping(true);
              } else if (index == 1) {
                index += 1;
                text = textList[index];
                _controller =
                    VideoPlayerController.asset("assets/videos/video3.mp4");
                initialisedVideoPlayer = _controller.initialize();
                _visible = true;
                _controller.play();
                _controller.setLooping(true);
              } else if (index == 2) {
                _controller.pause();
                Navigator.of(context).pushReplacement(CupertinoPageRoute(
                    builder: (context) => MainScreenWrapper(
                          index: 1,
                        )));
              }
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width / 4,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            _getBackgroundColor(),
            _getVideoBackground(),
            _getContent(),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  Offset offset = details.velocity.pixelsPerSecond;
                  if (offset.dx < 0) {
                    print(offset);
                    print("going forward");
                    if (index == 0) {
                      index += 1;
                      text = textList[index];
                      _controller = VideoPlayerController.asset(
                          "assets/videos/video${index + 1}.mp4");
                      initialisedVideoPlayer = _controller.initialize();
                      _visible = true;
                      _controller.play();
                      _controller.setLooping(true);
                    } else if (index == 1) {
                      index += 1;
                      text = textList[index];
                      _controller = VideoPlayerController.asset(
                          "assets/videos/video${index + 1}.mp4");
                      initialisedVideoPlayer = _controller.initialize();
                      _visible = true;
                      _controller.play();
                      _controller.setLooping(true);
                    } else if (index == 2) {
                      _controller.pause();
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (context) => MainScreenWrapper(
                                index: 1,
                              )));
                    }
                  } else if (offset.dx > 0) {
                    print(offset);
                    print("going backward");
                    if (index == 1) {
                      index -= 1;
                      text = textList[index];
                      _controller = VideoPlayerController.asset(
                          "assets/videos/video${index + 1}.mp4");
                      initialisedVideoPlayer = _controller.initialize();
                      _visible = true;
                      _controller.play();
                      _controller.setLooping(true);
                    } else if (index == 2) {
                      index -= 1;
                      text = textList[index];
                      _controller = VideoPlayerController.asset(
                          "assets/videos/video${index + 1}.mp4");
                      initialisedVideoPlayer = _controller.initialize();
                      _visible = true;
                      _controller.play();
                      _controller.setLooping(true);
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
