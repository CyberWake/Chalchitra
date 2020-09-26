import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoDataInputScreen.dart';
import 'package:flutter_colored_progress_indicators/flutter_colored_progress_indicators.dart';


class VideoUploader extends StatefulWidget {
  VideoUploader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  MediaInfo mediaInfo;
  bool _encodingFinished = false;
  bool _encodingVideo = false;
  String _processPhase = '';

  var videoFile;
  File thumbnailFile;
  double aspectRatio;
  String mediaInfoPath = ' ';
  String thumbnailInfoPath = ' ';
  String infoPath = ' ';


  Future<void> _processVideo(PickedFile rawVideoFile) async {
    print("processing");
    print(rawVideoFile.path);
    setState(() {
      _processPhase = 'Compressing video';
    });
    mediaInfo = await VideoCompress.compressVideo(
      rawVideoFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // It's false by default
    );
    setState(() {
      _processPhase = 'Getting thumbnail';
    });
    thumbnailFile = await VideoCompress.getFileThumbnail(
        rawVideoFile.path,
        quality: 100, // default(100)
        position: -1 // default(-1)
    );
    aspectRatio = mediaInfo.height/mediaInfo.width;
    mediaInfoPath = mediaInfo.path;
    thumbnailInfoPath = thumbnailFile.path;
    setState(() {
      _encodingVideo = false;
      _encodingFinished = true;
    });
  }


  void _takeVideo(context, source) async {
    videoFile = await ImagePicker().getVideo(
        source: source, maxDuration: const Duration(seconds: 300));

    if (videoFile == null) return;
    try {
      setState(() {
        _encodingVideo = true;
      });
      await _processVideo(videoFile);
    } catch (e) {
      print("error" + '${e.toString()}');
    } finally {
      print('Success');
    }

  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(),
        ],
      ),
    );
  }
  @override
  void initState() {
    _encodingFinished = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: _encodingVideo
                ? _getProgressBar()
                : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(50),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.15),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                            onPressed: () {
                              _encodingFinished = false;
                              _takeVideo(context, ImageSource.camera);
                            },
                            shape: RoundedRectangleBorder(
                                side:
                                BorderSide(color: Colors.orange.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text("Turn on Camera")
                        ),
                        FlatButton(
                            onPressed: () {
                              _encodingFinished = false;
                              _takeVideo(context, ImageSource.gallery);
                            },
                            shape: RoundedRectangleBorder(
                                side:
                                BorderSide(color: Colors.orange.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text("Pick from Gallery")
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    _encodingFinished && videoFile != null?FlatButton(
                        onPressed: () {
                          print("go to next screen");
                          Navigator.push(context, CupertinoPageRoute(
                            builder: (context) {
                              return VideoDataInput(mediainfoPath: mediaInfoPath, thumbnailPath: thumbnailInfoPath,aspectRatio: aspectRatio,);
                            }));
                        },
                        shape: RoundedRectangleBorder(
                            side:
                            BorderSide(color: Colors.orange.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text("Next")
                    )
                        :SizedBox()
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}