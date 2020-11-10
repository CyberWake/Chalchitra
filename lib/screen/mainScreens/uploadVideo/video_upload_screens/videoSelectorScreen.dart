import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/model/theme.dart';
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
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(videoInfo.duration < 90000
            ? "Select a video greater than 90 seconds duration"
            : "Select a video less than 300 seconds duration"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        key: _scaffoldGlobalKey,
        body: Stack(children: [
          NoDataTile(
            showButton: false,
            isActivity: false,
            titleText: " ",
            bodyText: " ",
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
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
                  Text(
                    "Showcase your Talent",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppTheme.primaryColor),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  _videoCheckOK
                      ? FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => VideoPreview(
                                          videoFile: videoFile,
                                        )));
                            print("go to preview screen");
                            setState(() {
                              _videoCheckOK = false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text("Next",
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                              )))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
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
            ),
            /*_encodingVideo
                  ? _getProgressBar()
                  : */
          ),
        ]));
  }
}
