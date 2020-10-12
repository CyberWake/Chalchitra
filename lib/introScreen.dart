import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class OnBoardScreen1 extends StatefulWidget {
  @override
  _OnBoardScreen1State createState() => _OnBoardScreen1State();
}

class _OnBoardScreen1State extends State<OnBoardScreen1> {
  VideoPlayerController _controller;
  String text = "It's your time to Shine.";
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller = VideoPlayerController.asset("assets/videos/video1.mp4");
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
      duration: Duration(milliseconds: 500),
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
            text,
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
          child: Platform.isIOS ? CupertinoButton(
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 20,color: Colors.black),
            ),
            color: Colors.white,
            onPressed: () {
              if(text == "It's your time to Shine."){
                text = "90 seconds to fame.";
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
              }else if(text == "90 seconds to fame."){
                text = "Rehearse. Record. Rise.";
                _controller = VideoPlayerController.asset("assets/videos/video3.mp4");
                _controller.initialize().then((_) {
                  _controller.setLooping(true);
                  Timer(Duration(milliseconds: 100), () {
                    setState(() {
                      _controller.play();
                      _visible = true;
                    });
                  });
                });
              }else if(text == "Rehearse. Record. Rise."){
                Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => MainScreenWrapper(index: 1,)));
              }

            },
          ) : FlatButton(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 20,color: AppTheme.backgroundColor),
            ),
            onPressed: () {
              if(text == "It's your time to Shine."){
                text = "90 seconds to fame.";
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
              }else if(text == "90 seconds to fame."){
                text = "Rehearse. Record. Rise.";
                _controller = VideoPlayerController.asset("assets/videos/video3.mp4");
                _controller.initialize().then((_) {
                  _controller.setLooping(true);
                  Timer(Duration(milliseconds: 100), () {
                    setState(() {
                      _controller.play();
                      _visible = true;
                    });
                  });
                });
              }else if(text == "Rehearse. Record. Rise."){
                Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => MainScreenWrapper(index: 1,)));
              }

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
    return Platform.isIOS ?CupertinoPageScaffold(
      child: Center(
        child: Stack(
          children: <Widget>[
            _getVideoBackground(),
            _getBackgroundColor(),
            _getContent(),
          ],
        ),
      ),
    ) : Scaffold(
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
