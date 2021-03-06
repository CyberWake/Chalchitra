import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:Chalchitra/imports.dart';

class PostCard extends StatefulWidget {
  final VideoInfo video;
  final String profileImg, uploader;
  final Function navigate;
  bool playVideo = false;

  PostCard(
      {this.video,
      this.navigate,
      this.profileImg,
      this.uploader,
      this.playVideo});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
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

  void button(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy - 20;
    showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      print(widget.video.videoId);
                      choiceAction(Menu.Share);
                    },
                    child: Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: AppTheme.pureWhiteColor,
                        ),
                        SizedBox(width: _size.width * 0.03),
                        Text(
                          Menu.Share,
                          style: TextStyle(color: AppTheme.pureWhiteColor),
                        )
                      ],
                    )),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      downloadIOS();
                    },
                    child: Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded,
                            color: AppTheme.pureWhiteColor),
                        SizedBox(width: _size.width * 0.03),
                        Text(Menu.Download,
                            style: TextStyle(color: AppTheme.pureWhiteColor))
                      ],
                    )),
                  ),
                  //  CupertinoActionSheetAction(onPressed: (){
                  //    choiceAction(Menu.Forward);
                  //  }, child:
                  //     Container(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.reply,color: AppTheme.pureWhiteColor),
                  //         SizedBox(width:_size.width*0.03),
                  //         Text(Menu.Forward,style: TextStyle(color: AppTheme.pureWhiteColor))
                  //       ],
                  //     )
                  // ),
                  //  ),
                ],
              );
            });
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
    } else if (choice == Menu.Download) {
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
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    if (oldWidget.playVideo != widget.playVideo) {
      if (widget.playVideo) {
        _controller.play();
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
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Container(
      height: _size.height * 0.4,
      width: _size.width * 0.9,
      decoration: BoxDecoration(
        color: AppTheme.pureWhiteColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: Offset(0.0, 0.0), //(x,y)
            blurRadius: 15.0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_fontOne * 12.5),
        child: _isLiked == null
            ? Container()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.profileImg,
                        imageBuilder: (context, imageProvider) => Container(
                          width: _fontOne * 40,
                          height: _heightOne * 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.backgroundColor,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
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
                      /*Container(
                        width: _fontOne * 40,
                        height: _heightOne * 40,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(widget.profileImg)),
                            borderRadius: BorderRadius.circular(10)),
                      ),*/
                      SizedBox(
                        width: _widthOne * 40,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.video.videoName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: _fontOne * 14,
                                color: AppTheme.pureBlackColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: _heightOne * 1.5,
                            ),
                            Text(
                              widget.uploader,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: _fontOne * 12,
                                  color: AppTheme.pureBlackColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: _widthOne * 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Icon(Icons.more_horiz,
                                color: Colors.grey, size: _iconOne * 30),
                            onTapDown: (TapDownDetails details) {
                              button(details.globalPosition);
                            },
                          ),
                          Text(
                            formatDateTime(
                                millisecondsSinceEpoch:
                                    widget.video.uploadedAt),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: _fontOne * 10,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: _heightOne * 15,
                  ),
                  Expanded(
                    child: InkWell(
                      // onTap: widget.navigate,
                      onTap: () async {
                        bool isWatched = await UserVideoStore()
                            .checkWatched(videoID: widget.video.videoId);
                        if (!isWatched) {
                          await UserVideoStore().increaseVideoCount(
                              videoID: widget.video.videoId);
                        }
                        widget.navigate();
                      },
                      child: widget.playVideo
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              child: _controller.value.initialized
                                  ? AspectRatio(
                                      aspectRatio:
                                          _controller.value.aspectRatio,
                                      child: VideoPlayer(_controller))
                                  : CachedNetworkImage(
                                      imageUrl: widget.video.thumbUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                          ),
                                          color: AppTheme.backgroundColor,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        highlightColor: AppTheme.pureWhiteColor,
                                        baseColor: AppTheme.backgroundColor,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            ),
                                            color: AppTheme.backgroundColor,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ))
                          : CachedNetworkImage(
                              imageUrl: widget.video.thumbUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                  color: AppTheme.backgroundColor,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Shimmer.fromColors(
                                highlightColor: AppTheme.pureWhiteColor,
                                baseColor: AppTheme.backgroundColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    color: AppTheme.backgroundColor,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: _heightOne * 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _widthOne * 30,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              child: !_isLiked
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
                              onTap: () async {
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
                                    _isLiked =
                                        !await _userVideoStore.dislikeVideo(
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
                            SizedBox(
                              width: _widthOne * 20,
                            ),
                            Text(
                              likeCount.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: _fontOne * 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: _widthOne * 40,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    Platform.isIOS
                                        ? CupertinoPageRoute(
                                            builder: (context) =>
                                                CommentsScreen(
                                                  videoId: widget.video.videoId,
                                                ))
                                        : MaterialPageRoute(
                                            builder: (context) =>
                                                CommentsScreen(
                                                  videoId: widget.video.videoId,
                                                )));
                              },
                              icon: Icon(
                                Icons.comment,
                                color: AppTheme.pureBlackColor,
                                size: _iconOne * 23,
                              ),
                            ),
                            SizedBox(
                              width: _widthOne * 20,
                            ),
                            FutureBuilder(
                              future: _userVideoStore.getComments(
                                  id: widget.video.videoId),
                              builder: (context, snap) {
                                if (snap.data == null) {
                                  return Text(
                                    widget.video.comments.toString() == null
                                        ? "0"
                                        : widget.video.comments.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: _fontOne * 14,
                                        color: Colors.grey),
                                  );
                                }
                                return Text(
                                  snap.data.docs.length == null
                                      ? "0"
                                      : snap.data.docs.length.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: _fontOne * 14,
                                      color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: _widthOne * 50,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackShape: RoundSliderTrackShape(),
                              trackHeight: 6.0,
                              thumbColor: Colors.orange[600],
                              thumbShape: StarThumb(thumbRadius: 20),
                              overlayColor: AppTheme.pureBlackColor,
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 18.0),
                            ),
                            child: Slider(
                              value: _sliderValue,
                              min: 0,
                              max: 5,
                              onChangeEnd: (val) async {
                                _sliderValue = val;
                                bool success = await _userVideoStore.rateVideo(
                                    videoID: widget.video.videoId,
                                    newRating: _sliderValue);
                                if (success) {
                                  print('done rating');
                                } else {
                                  print('failure');
                                }
                              },
                              onChanged: (val) {
                                setState(() {
                                  _sliderValue = val;
                                });
                              },
                              inactiveColor: AppTheme.backgroundColor,
                              activeColor: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
