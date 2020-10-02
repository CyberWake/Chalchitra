import 'package:animated_background/animated_background.dart';
import 'package:animated_background/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_uploader_widget/videoPreviewScreen.dart';


class VideoUploader extends StatefulWidget {
  VideoUploader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  MediaInfo videoInfo;
  bool _selected = false;
  bool _videoCheckOK = false;


  PickedFile videoFile;

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

  void _takeVideo(context, source) async {
    videoFile = await ImagePicker().getVideo(
        source: source, maxDuration: const Duration(seconds: 300));

    if (videoFile == null) return;
    setState(() {
      _selected = true;
    });
    videoInfo = await VideoCompress.getMediaInfo(videoFile.path);
    print(videoInfo.duration);
    if(videoInfo.duration >= 90000.0 && videoInfo.duration <= 300000.0)
    {
      setState(() {
        _videoCheckOK = true;
      });
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
                      _selected
                          ? SizedBox()
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FlatButton(
                              onPressed: () {
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
                      _videoCheckOK ? FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        VideoPreview(
                                          videoFile: videoFile,
                                        )
                                )
                            );
                            print("go to next screen");
                            _videoCheckOK = false;
                            _selected = false;
                          },
                          shape: RoundedRectangleBorder(
                              side:
                              BorderSide(color: Colors.orange.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text("Next")
                      ): SizedBox()
                    ],
                  ),
                ),
                /*_encodingVideo
                  ? _getProgressBar()
                  : */
              ),
            ),
          ]
        )
    );
  }
}