import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoDataInputScreen.dart';

class VideoPreview extends StatefulWidget {
  final PickedFile videoFile;
  VideoPreview({this.videoFile});
  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController _controller;
  File selectedVideo;
  bool playing;
  bool _encodingVideo = false;
  File thumbnailFile;
  double aspectRatio;
  String mediaInfoPath = ' ';
  String thumbnailInfoPath = ' ';
  String infoPath = ' ';
  String _processPhase = '';
  MediaInfo mediaInfo;

  Future<void> _processVideo(File rawVideoFile) async {
    print("processing");
    print(rawVideoFile.path);
    setState(() {
      _processPhase = "Encoding Video";
    });
    mediaInfo = await VideoCompress.compressVideo(
      rawVideoFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // It's false by default
    );
    setState(() {
      _processPhase = "Generating Thumbnail";
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
      Navigator.push(context, CupertinoPageRoute(
          builder: (context) {
            return VideoDataInput(mediaInfoPath: mediaInfoPath, thumbnailPath: thumbnailInfoPath,aspectRatio: aspectRatio,);
          }));
    });
  }

  @override
  void initState() {
    super.initState();
    selectedVideo = File(widget.videoFile.path);
    _encodingVideo = false;
    _controller = VideoPlayerController.file(selectedVideo)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
    _controller.play();
    playing = true;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Video Preview'),
      ),
      body: _encodingVideo
          ? _getProgressBar()
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: _controller.value.initialized?
                    InkWell(
                        onTap: (){
                          if(playing){
                            Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  content: Text('Audio Muted'),
                                )
                            );
                            playing = false;
                            _controller.setVolume(0.0);
                          }else{
                            Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  content: Text('Audio Unmuted'),
                                )
                            );
                            print("unmuted");
                            playing = true;
                            _controller.setVolume(1.0);
                          }
                        },
                        child: VideoPlayer(_controller)
                    )
                        :SpinKitCircle(
                      color: Colors.grey,
                      size: 60,
                    )
                ),
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(playedColor: Colors.orange,bufferedColor: Colors.grey,backgroundColor: Colors.white),),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        child: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      bottomSheet: Container(
        padding: EdgeInsets.only(bottom: 10),
        color: Colors.black,
//        height: MediaQuery.of(context).size.height *0.08,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: ()async{
                Navigator.pop(context);
              },
              child: Text('Get New Video',
                style: TextStyle(color: Colors.white,fontSize: 20),),
            ),
            FlatButton(
              onPressed: ()async{
                setState(() {
                  _encodingVideo = true;
                });
                await _processVideo(selectedVideo);
              },
              child: Text('Encode',
                  style: TextStyle(color: Colors.white,fontSize: 20)),),
          ],
        ),
      ),
    );
  }
}
