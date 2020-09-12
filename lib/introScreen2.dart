import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:wowtalent/introScreen3.dart';

class OnBoardScreen2 extends StatefulWidget {
  @override
  _OnBoardScreen2State createState() => _OnBoardScreen2State();
}

class _OnBoardScreen2State extends State<OnBoardScreen2> {
  VideoPlayerController _controller;
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller = VideoPlayerController.asset("assets/videos/video2.mp4");
    _controller.initialize().then((_) {
      _controller.setLooping(true);
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          _controller.play();
          _visible = true;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller.dispose();
      _controller = null;
    }
  }
  _getVideoBackground() {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: VideoPlayer(_controller),
    );
  }
  _getBackgroundColor() {
    return Container(
      color: Colors.black12.withAlpha(120),
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
            "90 seconds to fame.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 28,fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width/8,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
          width: MediaQuery.of(context).size.width/2,
          child: FlatButton(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 20,color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(CupertinoPageRoute(builder: (_) => OnBoardScreen3()));
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width/4,
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
            _getVideoBackground(),
            _getBackgroundColor(),
            _getContent(),
          ],
        ),
      ),
    );
  }
}
