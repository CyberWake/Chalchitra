import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:animated_background/particles.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/ios_Screens/uploadVideo/video_upload_screens/videoSelectorIOS.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_upload_screens/videoPreviewScreen.dart';
import 'package:wowtalent/widgets/noDataTile.dart';

class VideoUploader extends StatefulWidget {
  VideoUploader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey =
      GlobalKey<ScaffoldState>();
  MediaInfo videoInfo;
  bool _selected = false;
  bool _videoCheckOK = false;

  PickedFile videoFile;

  void _takeVideo(context, source) async {
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
    return Platform.isIOS
        ? VideoSelectorIOS(
            selectorBody: selectorBody(),
          )
        : Scaffold(
            backgroundColor: AppTheme.primaryColor,
            key: _scaffoldGlobalKey,
            body: selectorBody());
  }

  Widget selectorBody() {
    return Stack(children: [
      Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   "Showcase your Talent",
              //   style: TextStyle(
              //       fontSize: 22,
              //       fontWeight: FontWeight.bold,
              //       color: AppTheme.pureBlackColor),
              // ),
              // SizedBox(
              //   height: 10.0,
              // ),
              _videoCheckOK
                  ? OpenContainer(
                      closedElevation: 0.0,
                      closedColor: Colors.transparent,
                      tappable: false,
                      transitionDuration: Duration(milliseconds: 500),
                      openBuilder: (BuildContext context,
                          void Function({Object returnValue}) action) {
                        Future.delayed(Duration.zero, () async {
                          setState(() {
                            _videoCheckOK = false;
                          });
                        });
                        return VideoPreview(
                          videoFile: videoFile,
                        );
                      },
                      closedBuilder:
                          (BuildContext context, void Function() action) {
                        return Platform.isIOS
                            ? CupertinoButton(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(25),
                                onPressed: () => action(),
                                child: Text("Next",
                                    style: TextStyle(
                                      color: AppTheme.pureWhiteColor,
                                      fontSize: 18
                                    )))
                            : FlatButton(
                                onPressed: () => action(),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: AppTheme.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text("Next",
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 18
                                    )));
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: Platform.isIOS
                          ? [
                              CupertinoButton(
                                borderRadius: BorderRadius.circular(25),
                                onPressed: () {
                                  _takeVideo(context, ImageSource.camera);
                                },
                                child: Text(
                                  "Turn on Camera",
                                  style:
                                      TextStyle(color: AppTheme.pureWhiteColor),
                                ),
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              CupertinoButton(
                                borderRadius: BorderRadius.circular(25),
                                onPressed: () {
                                  _takeVideo(context, ImageSource.gallery);
                                },
                                child: Text(
                                  "Pick from Gallery",
                                  style:
                                      TextStyle(color: AppTheme.pureWhiteColor),
                                ),
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ]
                          : [
                              FlatButton(
                                  onPressed: () {
                                    _takeVideo(context, ImageSource.camera);
                                  },
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: AppTheme.primaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(" Turn on Camera ",
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                      ))),
                              FlatButton(
                                  onPressed: () {
                                    _takeVideo(context, ImageSource.gallery);
                                  },
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: AppTheme.primaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text("Pick from Gallery",
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                      ))),
                            ],
                    ),
            ],
          ),
          /*_encodingVideo
                  ? _getProgressBar()
                  : */
        ),
      ),
    ]);
  }
}
