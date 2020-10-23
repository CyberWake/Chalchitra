import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/database/dynamicLinkService.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

class SplashScreen extends StatefulWidget {
  final dynamic navigateAfterSeconds;
  SplashScreen({
    this.navigateAfterSeconds,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  DynamicLinkService links = DynamicLinkService();
  Timer _timerLink;

  _retrieveDynamicLink() async {
    await links.handleDynamicLinks(context, true);
    if (!links.isFromLink) {
      Timer(Duration(seconds: 4), () {
        print("Pushing navigate after page");
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (BuildContext context) => widget.navigateAfterSeconds));
      });
    } else {
      Timer(Duration(seconds: 4), () {
        print("Pushing player");
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (BuildContext context) => Player(
              videos: links.videos,
              index: 0,
            )));
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("running did change");
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(const Duration(milliseconds: 850), () {
        _retrieveDynamicLink();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("running binding");
    WidgetsBinding.instance.addObserver(this);
    print("running dynamic link");
    _retrieveDynamicLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        child: Image.asset('assets/images/splash.png'),
                      ),
                      radius: 100.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                  ],
                )),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: index.isEven ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
