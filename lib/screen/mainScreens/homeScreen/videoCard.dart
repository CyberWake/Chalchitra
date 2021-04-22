import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:Chalchitra/imports.dart';

class VideoCard extends StatefulWidget {
  final VideoInfo video;
  final String profileImg, uploader;
  final Function navigate;
  bool playVideo = false;

  VideoCard(
      {this.navigate,
      this.playVideo,
      this.profileImg,
      this.uploader,
      this.video});
  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  double _widthOne;
  double _heightOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  double _sliderValue;
  UserVideoStore _userVideoStore = UserVideoStore();
  UserDataModel _user = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _userAuth = UserAuth();
  bool _isLiked;
  int likeCount;
  bool _processing = false;
  VideoPlayerController _controller;

  void _button(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy + 10;
    await showMenu(
        context: context,
        color: AppTheme.pureWhiteColor,
        position: RelativeRect.fromLTRB(left, 100, 20, 0),
        items: [
          PopupMenuItem(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () => choiceAction(Menu.Share),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Menu.Share,
                        style: TextStyle(color: AppTheme.pureBlackColor),
                      ),
                      Icon(Icons.share, size: 18, color: Colors.blueAccent),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () => choiceAction(Menu.Download),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Menu.Download,
                        style: TextStyle(color: AppTheme.pureBlackColor),
                      ),
                      Icon(Icons.arrow_downward, size: 20, color: Colors.green),
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // InkWell(
                //   onTap: () => choiceAction(Menu.Forward),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         Menu.Forward,
                //         style: TextStyle(color: AppTheme.pureBlackColor),
                //       ),
                //       Transform(
                //         alignment: Alignment.center,
                //         transform: Matrix4.rotationY(3.1415926535897932),
                //         child: Icon(
                //           Icons.reply,
                //           size: 20,
                //           color: Colors.orangeAccent,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        ]);
  }



  void downloadIOS() async {
    Dio dio = Dio();
    String time = DateTime.now().toString();
    final directoryIOS = await getApplicationDocumentsDirectory();
    try {
      cupertinoSnackbar(context, "Download Started");
      await dio.download(widget.video.videoUrl,
          '${directoryIOS.path}/${time.substring(0, time.lastIndexOf("."))}/video.mp4',
          onReceiveProgress: (received, total) {
        if (total == received) {
          cupertinoSnackbar(context, "Download Complete");
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }


  void choiceAction(String choice) async {
    print('called');
    if (choice == Menu.Share) {
      Navigator.pop(context);
      await FlutterShare.share(
          title: 'Watch WowTalent',
          text:
              "I'm loving this app, WowTalent, world's largest talent discovery platform. I found new talent :",
          linkUrl: widget.video.shareUrl,
          chooserTitle: 'Share');
    } else if (choice == Menu.Download && !Platform.isIOS) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      } else if (status.isGranted) {
        print('Download');
        String directory;
        Directory('/storage/emulated/0/WowTalent').create()
            // The created directory is returned as a Future.
            .then((Directory directoryPath) {
          print(directoryPath.path);
          directory = directoryPath.path;
        });
        Scaffold.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text('Download Started'),
        ));
        Dio dio = Dio();
        String time = DateTime.now().toString();
        try {
          Navigator.pop(context);
          await dio.download(widget.video.videoUrl,
              '/storage/emulated/0/WowTalent/${time.substring(0, time.lastIndexOf("."))}/video.mp4',
              onReceiveProgress: (received, total) {
            if (total == received) {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(milliseconds: 1000),
                content: Text('Download Completed'),
              ));
            }
          });
        } catch (e) {
          print(e.toString());
        }
      } else {
        Navigator.pop(context);
      }
    } else if (choice == Menu.Forward) {
      print('Forward');
      Navigator.pop(context);
    }else if(choice == Menu.Download && Platform.isIOS){
      downloadIOS();
      print("iosdownload");
    }
  }

  void setup() async {
    DocumentSnapshot user =
        await _userInfoStore.getUserInfo(uid: widget.video.uploaderUid);
    _user = UserDataModel.fromDocument(user);
    _sliderValue =
        await _userVideoStore.checkRated(videoID: widget.video.videoId);
    _isLiked = await _userVideoStore.checkLiked(videoID: widget.video.videoId);
    likeCount = widget.video.likes;
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
    _controller = VideoPlayerController.network(widget.video.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    if (widget.playVideo) {
      _controller.play();
      _controller.setVolume(1);
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    if (oldWidget.playVideo != widget.playVideo) {
      if (widget.playVideo) {
        _controller.play();
        _controller.setVolume(1);
        _controller.setLooping(true);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: AppTheme.pureBlackColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: (){
              _controller.setVolume(0);
              widget.navigate();
            },
            child: Container(
              color: AppTheme.pureBlackColor,
              child: widget.playVideo
                  ? Container(
                      child: _controller.value.initialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller))
                          : CachedNetworkImage(
                              imageUrl: widget.video.thumbUrl,
                              imageBuilder: (context, imageProvider) =>
                                  AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.none),
                                        ),
                                      )),
                              placeholder: (context, url) => Shimmer.fromColors(
                                highlightColor: AppTheme.pureWhiteColor,
                                baseColor: AppTheme.backgroundColor,
                                child: Container(),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ))
                  : CachedNetworkImage(
                      imageUrl: widget.video.thumbUrl,
                      imageBuilder: (context, imageProvider) => AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.none),
                            ),
                          )),
                      placeholder: (context, url) => Shimmer.fromColors(
                        highlightColor: AppTheme.pureWhiteColor,
                        baseColor: AppTheme.backgroundColor,
                        child: Container(),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),
          ),
          Positioned(
            bottom: 6.0,
            child: Container(
              width: _size.width,
              child: ListTile(
                title: Text(
                  "${widget.video.videoName} • ${widget.video.videoHashtag} ",
                  style: TextStyle(color: AppTheme.pureWhiteColor),
                ),
                subtitle: Text(
                  widget.uploader,
                  style: TextStyle(color: AppTheme.pureWhiteColor),
                ),
                trailing: _isLiked == null
                    ? Container(
                        child: SvgPicture.asset(
                          "assets/images/love_icon.svg",
                          width: 20,
                          color: AppTheme.secondaryColorDark,
                        ),
                      )
                    : IconButton(
                        icon: !_isLiked
                            ? SvgPicture.asset(
                                "assets/images/love_icon.svg",
                                width: 20,
                                color: AppTheme.secondaryColorDark,
                              )
                            : SvgPicture.asset(
                                "assets/images/loved_icon.svg",
                                width: 20,
                                color: AppTheme.secondaryColor,
                              ),
                        onPressed: () async {
                          if (!_processing) {
                            _processing = true;
                            if (!_isLiked) {
                              _isLiked = await _userVideoStore.likeVideo(
                                videoID: widget.video.videoId,
                              );
                              if (_isLiked) {
                                likeCount += 1;
                              }
                            } else {
                              setState(() {
                                _isLiked = !_isLiked;
                              });
                              _isLiked = !await _userVideoStore.dislikeVideo(
                                videoID: widget.video.videoId,
                              );
                              if (!_isLiked) {
                                likeCount -= 1;
                              }
                            }
                            _processing = false;
                          } else {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          }
                          setState(() {});
                        },
                      ),
                leading: CachedNetworkImage(
                  imageUrl: widget.profileImg,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                    radius: _heightOne * 30,
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    highlightColor: AppTheme.pureWhiteColor,
                    baseColor: AppTheme.backgroundColor,
                    child: Container(
                      width: _fontOne * 40,
                      height: _heightOne * 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppTheme.backgroundColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            // top: 80,
            // left: _size.width - 50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: Icon(Icons.more_horiz,
                    color: Colors.white, size: _iconOne * 30),
                onTapDown: (TapDownDetails details) {
                  _button(details.globalPosition);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
