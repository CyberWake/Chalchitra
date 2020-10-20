import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/model/theme.dart';

import '../../../../model/theme.dart';
import 'videoDataInputScreen.dart';

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
  Size _size;

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
      position: _controller.value.position.inSeconds - 1, // default(-1)
    );
    aspectRatio = mediaInfo.height / mediaInfo.width;
    mediaInfoPath = mediaInfo.path;
    thumbnailInfoPath = thumbnailFile.path;
    setState(() {
      Navigator.push(context, CupertinoPageRoute(builder: (context) {
        return VideoDataInput(
          mediaInfoPath: mediaInfoPath,
          thumbnailPath: thumbnailInfoPath,
          aspectRatio: aspectRatio,
        );
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
            child: Text(
              _processPhase,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Platform.isIOS
              ? LinearProgressIndicator(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                )
              : LinearProgressIndicator(),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() {
    try {
      Navigator.pop(context);
      return _controller.pause() ?? false;
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldGlobalKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          title: Text('Video Preview'),
        ),
        body: previewBody(),
        bottomNavigationBar: previewBottomNav(),
      ),
    );
  }

  currPos() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        return Text(
          value.position == null ? "" : trimDuration(value.position),
          style: TextStyle(color: AppTheme.pureWhiteColor),
        );
      },
    );
  }

  String trimDuration(Duration duration) {
    num min = duration.inMinutes;
    num sec = duration.inSeconds.remainder(60);
    if (sec < 10) {
      return "$min:0$sec";
    } else {
      return "${duration.inMinutes}:${duration.inSeconds.remainder(60)}";
    }
  }

  Widget previewBody() {
    return _encodingVideo
        ? _getProgressBar()
        : _controller.value.initialized
            ? Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Select a frame for the Thumbnail",
                          style: TextStyle(
                              color: AppTheme.backgroundColor, fontSize: 20),
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: InkWell(
                            onTap: () {
                              if (playing) {
                                print("running");
                                _scaffoldGlobalKey.currentState
                                    .showSnackBar(SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  content: Text('Audio Muted'),
                                ));
                                print("running");
                                playing = false;
                                _controller.setVolume(0.0);
                              } else {
                                _scaffoldGlobalKey.currentState
                                    .showSnackBar(SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  content: Text('Audio Unmuted'),
                                ));
                                playing = true;
                                _controller.setVolume(1.0);
                              }
                            },
                            child: VideoPlayer(_controller)),
                      ),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                            playedColor: AppTheme.primaryColor,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            currPos(),
                            Text(
                              _controller.value.duration == null
                                  ? ""
                                  : trimDuration(_controller.value.duration),
                              style: TextStyle(color: AppTheme.pureWhiteColor),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.68,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 25.0, bottom: 10),
                            child: FloatingActionButton(
                              backgroundColor: AppTheme.primaryColor,
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )
            : SpinKitCircle(
                color: Colors.grey,
                size: 60,
              );
  }

  Widget previewBottomNav() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      color: Colors.black,
//        height: MediaQuery.of(context).size.height *0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: Platform.isIOS
            ? [
                CupertinoButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    _controller.pause();
                  },
                  child: Text(
                    'Get New Video',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                CupertinoButton(
                  onPressed: () async {
                    setState(() {
                      _controller.pause();
                      _encodingVideo = true;
                    });
                    await _processVideo(selectedVideo);
                  },
                  child: Text(_encodingVideo ? 'Encoding..' : 'Encode',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                )
              ]
            : [
                FlatButton(
                  onPressed: () async {
                    _controller.pause();
                    VideoCompress.cancelCompression();
                    await VideoCompress.deleteAllCache();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Get New Video',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                FlatButton(
                  onPressed: () async {
                    setState(() {
                      _controller.pause();
                      _encodingVideo = true;
                    });
                    await _processVideo(selectedVideo);
                  },
                  child: Text(_encodingVideo ? 'Encoding..' : 'Encode',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ],
      ),
    );
  }
}
