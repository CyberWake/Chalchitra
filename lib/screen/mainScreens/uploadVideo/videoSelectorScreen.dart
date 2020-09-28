import 'dart:io';
import 'package:animated_background/animated_background.dart';
import 'package:animated_background/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoDataInputScreen.dart';


class VideoUploader extends StatefulWidget {
  VideoUploader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  VideoPlayerController controller;
  MediaInfo mediaInfo;
  MediaInfo videoInfo;
  bool _encodingFinished = false;
  bool _encodingVideo = false;
  String _processPhase = '';

  PickedFile videoFile;
  File thumbnailFile;
  double aspectRatio;
  String mediaInfoPath = ' ';
  String thumbnailInfoPath = ' ';
  String infoPath = ' ';

  ParticleOptions particleOptions = ParticleOptions(
    image: Image.asset('assets/images/star_stroke.png'),
    baseColor: Colors.blue,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.1,
    maxOpacity: 0.4,
    spawnMinSpeed: 30.0,
    spawnMaxSpeed: 70.0,
    spawnMinRadius: 7.0,
    spawnMaxRadius: 15.0,
    particleCount: 40,
  );

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;


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
    videoInfo = await VideoCompress.getMediaInfo(videoFile.path);
    print(videoInfo.duration);
    if(videoInfo.duration >= 90000.0 && videoInfo.duration <= 300000.0)
    {
      try {
        setState(() {
          _encodingVideo = true;
        });
        await _processVideo(videoFile);
      } catch (e) {
        print("error" + '${e.toString()}');
      } finally {
        print('Success');
        print(videoInfo.duration);
      }
    }else{
      Scaffold.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  videoInfo.duration < 90000
                  ?"Select a video greater than 90 seconds duration"
                      :"Select a video less than 300 seconds duration"),
          )
      );
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
      key: _scaffoldGlobalKey,
        body: Stack(
          children: [
            AnimatedBackground(
            behaviour: RandomParticleBehaviour(
            options: particleOptions,
              paint: particlePaint,
            ),
            vsync: this,
            child: Center(
              child: _encodingVideo
                  ? _getProgressBar()
                  : Container(
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
                              setState(() {
                                _encodingFinished = false;
                              });
                              print("go to next screen");
                              Navigator.push(context, CupertinoPageRoute(
                                builder: (context) {
                                  return VideoDataInput(mediaInfoPath: mediaInfoPath, thumbnailPath: thumbnailInfoPath,aspectRatio: aspectRatio,);
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
            ]
        )
    );
  }
}