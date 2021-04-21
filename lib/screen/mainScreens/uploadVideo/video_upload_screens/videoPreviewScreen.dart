import 'dart:async';
import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:video_compress/src/progress_callback.dart/subscription.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/ios_Screens/uploadVideo/video_upload_screens/videoPreviewIOS.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_upload_screens/videoUploadForm.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';

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
  Subscription _subscription;
  double _progress = 0.0;
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
      _processPhase = "Processing Video";
    });
    mediaInfo = await VideoCompress.compressVideo(
      rawVideoFile.path,
      includeAudio: true,
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
        return VideoUploadForm(
          isFromDraft: false,
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
    _subscription = VideoCompress.compressProgress$.subscribe((event) {
      setState(() {
        _progress = event.roundToDouble();
      });
    });
    super.initState();
    selectedVideo = File(widget.videoFile.path);
    print(selectedVideo);
    _encodingVideo = false;
    _controller = VideoPlayerController.file(selectedVideo)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
    _controller.play();
    playing = true;
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller == null) {
      _controller.dispose();
    } else {
      _controller = null;
      _controller.dispose();
      _subscription.unsubscribe();
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
            child: Text(
              _processPhase,
              style: TextStyle(color: AppTheme.pureWhiteColor, fontSize: 20),
            ),
          ),
          LinearPercentIndicator(
            alignment: MainAxisAlignment.center,
            width: MediaQuery.of(context).size.width * 0.8,
            animation: false,
            lineHeight: 20.0,
            animationDuration: 2500,
            percent: _progress / 100,
            center: Text('$_progress%', style: TextStyle(color: Colors.black)),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  // ignore: missing_return
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
      child: Platform.isIOS
          ? VideoPreviewIOS(
              previewBody: previewBody(),
              previewBottomNav: previewBottomNav(),
            )
          : Scaffold(
              key: _scaffoldGlobalKey,
              backgroundColor: AppTheme.primaryColor,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: AppTheme.primaryColor,
                title: Text(
                  'Video Preview',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 21,
                  )
                ),
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
            ? SingleChildScrollView(
              child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Select a frame for the thumbnail",
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 20),
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Platform.isIOS
                              ? CupertinoButton(
                                  onPressed: () {
                                    if (playing) {
                                      print("running");
                                      cupertinoSnackbar(context, "Audio Muted");
                                      print("running");
                                      playing = false;
                                      _controller.setVolume(1.0);
                                    } else {
                                      cupertinoSnackbar(context, "Audio Unmuted");
                                      playing = true;
                                      _controller.setVolume(1.0);
                                    }
                                  },
                                  child: VideoPlayer(_controller))
                              : InkWell(
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
                                      _controller.setVolume(1.0);
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
                              playedColor: AppTheme.secondaryColor,
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
                                backgroundColor: AppTheme.secondaryColor,
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
                ),
            )
            : SpinKitCircle(
                color: Colors.grey,
                size: 60,
              );
  }

  Widget previewBottomNav() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      color: AppTheme.primaryColor,
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
                    style:
                        TextStyle(color: AppTheme.secondaryColor, fontSize: 20),
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
                  child: Text(
                    _encodingVideo ? 'Processing..' : 'Next',
                    style:
                        TextStyle(color: AppTheme.secondaryColor, fontSize: 20),
                  ),
                )
              ]
            : [
                FlatButton(
                  onPressed: () async {
                    _controller.pause();
                    VideoCompress.cancelCompression();
                    await VideoCompress.deleteAllCache();
                    _subscription.unsubscribe();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Get New Video',
                    style:
                        TextStyle(color: AppTheme.secondaryColor, fontSize: 20),
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
                  child: Text(_encodingVideo ? 'Processing..' : 'Next',
                      style: TextStyle(
                          color: AppTheme.secondaryColor, fontSize: 20)),
                ),
              ],
      ),
    );
  }
}
