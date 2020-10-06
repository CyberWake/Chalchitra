import 'dart:io';
import 'package:flushbar/flushbar.dart';
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
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
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
      _encodingVideo = false;
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
            child: Text(_processPhase,style: TextStyle(color: Colors.white,decoration: Platform.isIOS ? TextDecoration.none:null),),
          ),
          LinearProgressIndicator(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _heightOne = MediaQuery.of(context).size.height*0.1;
    return Platform.isIOS ? CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: CupertinoNavigationBar(
        middle: Text("Video Preview"),
      ),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          _encodingVideo
          ? _getProgressBar()
          : _controller.value.initialized
          ? Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child:
                CupertinoButton(
                    onPressed: (){
                      if(playing){
                        print("running");
                        Flushbar(
                          maxWidth: _size.width*0.5,
                          borderRadius: 20,
                          animationDuration: Duration(milliseconds: 500),
                          flushbarPosition: FlushbarPosition.BOTTOM,
                          flushbarStyle: FlushbarStyle.FLOATING,
                          backgroundColor: CupertinoColors.systemGrey,
                          messageText: Text("Audio muted",textAlign: TextAlign.center,),
                          titleText: Container(child:Icon(Icons.volume_off)),
                          duration: Duration(milliseconds: 500),
                          padding: EdgeInsets.all(10),
                        )..show(context);
                        print("running");
                        playing = false;
                        _controller.setVolume(0.0);
                      }else{
                        Flushbar(
                          maxWidth: _size.width*0.5,
                          borderRadius:20,
                          messageText: Text("Audio Unmuted",textAlign: TextAlign.center,),
                          animationDuration: Duration(milliseconds: 500),
                          flushbarPosition: FlushbarPosition.BOTTOM,
                          flushbarStyle: FlushbarStyle.FLOATING,
                          backgroundColor: CupertinoColors.systemGrey,
                          titleText: Icon(Icons.volume_up),
                          duration: Duration(milliseconds: 500),
                          padding: EdgeInsets.all(10),
                        )..show(context);
                        playing = true;
                        _controller.setVolume(1.0);
                      }
                    },
                    child: VideoPlayer(_controller)
                ),

              ),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                    playedColor: Colors.orange,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.68,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 25.0,bottom: 10),
                    child: FloatingActionButton(
                      backgroundColor: CupertinoTheme.of(context).primaryColor,
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
          )
        ],
      ):SpinKitCircle(
        color: Colors.grey,
        size: 60,
      ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            color: Colors.black,
//        height: MediaQuery.of(context).size.height *0.08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: ()async{
                    Navigator.pop(context);
                    _controller.pause();
                  },
                  child: Text('Get New Video',
                    style: TextStyle(color: Colors.white,fontSize: 20),),
                ),
                CupertinoButton(
                  onPressed: ()async{
                    setState(() {
                      _controller.pause();
                      _encodingVideo = true;
                    });
                    await _processVideo(selectedVideo);
                  },
                  child: Text(_encodingVideo ?'Encoding..':'Encode',
                      style: TextStyle(color: Colors.white,fontSize: 20)),),
              ],
            ),
          ),
        ])
    ): Scaffold(
      key: _scaffoldGlobalKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Video Preview'),
      ),
      body: _encodingVideo
          ? _getProgressBar()
          : _controller.value.initialized
              ? Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child:
                        InkWell(
                            onTap: (){
                              if(playing){
                                print("running");
                                _scaffoldGlobalKey.currentState.showSnackBar(
                                    SnackBar(
                                      duration: Duration(milliseconds: 500),
                                      content: Text('Audio Muted'),
                                    )
                                );
                                print("running");
                                playing = false;
                                _controller.setVolume(0.0);
                              }else{
                                _scaffoldGlobalKey.currentState.showSnackBar(
                                    SnackBar(
                                      duration: Duration(milliseconds: 500),
                                      content: Text('Audio Unmuted'),
                                    )
                                );
                                playing = true;
                                _controller.setVolume(1.0);
                              }
                            },
                            child: VideoPlayer(_controller)
                        ),

                      ),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                            playedColor: Colors.orange,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.68,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 25.0,bottom: 10),
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
                  )
                ],
              ):SpinKitCircle(
            color: Colors.grey,
            size: 60,
          ),
      bottomNavigationBar: Container(
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
                  _controller.pause();
                  _encodingVideo = true;
                });
                await _processVideo(selectedVideo);
              },
              child: Text(_encodingVideo ?'Encoding..':'Encode',
                  style: TextStyle(color: Colors.white,fontSize: 20)),),
          ],
        ),
      ),
    );
  }
}
