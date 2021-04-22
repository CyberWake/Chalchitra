import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class CustomFAB extends StatefulWidget {
  @override
  _CustomFABState createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  Animation rotationAnimation;
  Animation mainBtnAnimation;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    rotationAnimation = Tween(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    mainBtnAnimation = Tween(begin: 180.0, end: 45.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldGlobalKey =
    GlobalKey<ScaffoldState>();
  MediaInfo videoInfo;
  bool _selected = false;
  bool _videoCheckOK = false;

  PickedFile videoFile;

  _takeVideo(context, source) async {
    videoFile = await ImagePicker()
        .getVideo(source: source, maxDuration: const Duration(seconds: 300));

    if (videoFile == null) return;
    videoInfo = await VideoCompress.getMediaInfo(videoFile.path);
    print(videoInfo.duration);
    if (videoInfo.duration >= 90000.0 && videoInfo.duration <= 300000.0) {
      setState(() {
        _selected = true;
        _videoCheckOK = true;
      });
     
    } else {
      Platform.isIOS
          ? showCupertinoModalPopup(
              context: context,
              builder: (_) {
                return CupertinoActionSheet(
                  cancelButton: CupertinoButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  message: Text(
                    videoInfo.duration < 90000
                        ? "Select a video greater than 90 seconds duration"
                        : "Select a video less than 300 seconds duration",
                    style: TextStyle(fontSize: 14),
                  ),
                );
              })
          : Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(videoInfo.duration < 90000
                  ? "Select a video greater than 90 seconds duration"
                  : "Select a video less than 300 seconds duration"),
            ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(225),
                      degOneTranslationAnimation.value * 100),
                  child: Transform(
                    transform: Matrix4.rotationZ(
                        getRadianFromDegree(rotationAnimation.value))
                      ..scale(degOneTranslationAnimation.value),
                    alignment: Alignment.center,
                    child: Container(
                      color: Colors.white,
                      child: CircularButton(
                        color: Color(0xFFCCA969), //make this color in theme
                        width: 50,
                        height: 50,
                        icon: Icon(Icons.camera_alt),
                        onClick: () {
                          print('Camera pressed');
                        },
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(315),
                      degTwoTranslationAnimation.value * 100),
                  child: Transform(
                    transform: Matrix4.rotationZ(
                        getRadianFromDegree(rotationAnimation.value))
                      ..scale(degTwoTranslationAnimation.value),
                    alignment: Alignment.center,
                    child: CircularButton(
                      onClick: () {
                        print("ok");
                      _takeVideo(context, ImageSource.gallery);
                      },
                      width: 50,
                      height: 50,
                      color: Color(0xFFCCA969),
                      icon: Icon(Icons.photo_camera_back),
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.rotationZ(
                      getRadianFromDegree(mainBtnAnimation.value)),
                  alignment: Alignment.center,
                  child: CircularButton(
                    color: Color(0xFFCCA969),
                    icon: Icon(Icons.add),
                    width: 45,
                    height: 45,
                    onClick: () {
                      if (animationController.isCompleted) {
                        animationController.reverse();
                      } else {
                        animationController.forward();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton(
      {this.color, this.width, this.height, this.icon, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(
        icon: icon,
        onPressed: onClick,
        enableFeedback: true,
      ),
    );
  }
}
