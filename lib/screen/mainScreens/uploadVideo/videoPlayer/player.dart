import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_stack/swipe_stack.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/ios_Screens/uploadVideo/video_player/playerIOS.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';
import 'package:wowtalent/widgets/customSliderThumb.dart';
import 'package:wowtalent/widgets/customSliderTrackShape.dart';

class Player extends StatefulWidget {
  final UserDataModel user;
  final List<VideoInfo> videos;
  final int index;
  Player({Key key, this.user, this.videos, this.index}) : super(key: key);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  final _swiperStack = GlobalKey<SwipeStackState>();
  UserAuth _userAuth = UserAuth();
  VideoPlayerController _controller;
  double _widthOne;
  double _sliderValue = 0.0;
  Size _size;
  double _fontOne;
  double _iconOne;
  UserVideoStore _userVideoStore = UserVideoStore();
  int likeCount = 0;
  int commentCount = 0;
  int currentPos;
  bool _isLiked = false;
  bool unmute;
  bool playing;
  bool loading = true;
  bool isPotrait = false;
  UserDataModel _user = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  bool _boolFutureCalled = false;
  bool _following = false;
  bool _processing = false;
  bool showUnmuteAudio = false;
  bool showMuteAudio = false;
  PageController vidPageController;

  Future<bool> setup() async {
    if (!_boolFutureCalled) {
      try {
        if (_userAuth.user != null) {
          _following = await _userInfoStore.checkIfAlreadyFollowing(
              uid: widget.videos[currentPos].uploaderUid);
        }
        likeCount = widget.videos[currentPos].likes;

        _sliderValue = await _userVideoStore.checkRated(
            videoID: widget.videos[currentPos].videoId);
        print(_sliderValue);
        _isLiked = await _userVideoStore.checkLiked(
            videoID: widget.videos[currentPos].videoId);
        _boolFutureCalled = true;
        setState(() {});
        return true;
      } catch (e) {
        print(e.toString());
        return false;
      }
    } else {
      return true;
    }
  }

  getUserInfo() async {
    DocumentSnapshot user = await _userInfoStore.getUserInfo(
        uid: widget.videos[currentPos].uploaderUid);
    _user = UserDataModel.fromDocument(user);
    setState(() {
      loading = false;
    });
  }

  mySetup() {
    _controller =
        VideoPlayerController.network(widget.videos[currentPos].videoUrl)
          ..initialize().then((_) {
            setState(() {});
          });
    setup();
    getUserInfo();
    _controller.play();
    playing = _controller.value.isPlaying;
    unmute = true;
  }

  @override
  void initState() {
    currentPos = widget.index;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
    mySetup();
  }

  Future<bool> button(bool isLiked) async {
    if (_userAuth.user == null) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Authentication(AuthIndex.REGISTER);
          },
        ),
      );
    } else if (_isLiked == false) {
      _isLiked = await _userVideoStore.likeVideo(
        videoID: widget.videos[currentPos].videoId,
      );
    } else if (_isLiked == true) {
      _isLiked = await _userVideoStore.dislikeVideo(
        videoID: widget.videos[currentPos].videoId,
      );
    }
    return _isLiked;
  }

  String getChoppedUsername(String currentDescription) {
    String choppedDescription = '';
    var subDisplayName = currentDescription.split(' ');
    for (var i in subDisplayName) {
      if (choppedDescription.length + i.length < 36) {
        choppedDescription += ' ' + i;
      } else {
        return choppedDescription + ' ...';
      }
    }
    return choppedDescription + ' ...';
  }

  Future<bool> _onBackPressed() {
    try {
      Navigator.pop(context);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      return _controller.pause() ?? false;
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<bool> _onLikedPressed() async {
    if (_userAuth.user == null) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Authentication(AuthIndex.REGISTER);
          },
        ),
      );
    } else {
      if (!_processing) {
        _processing = true;
        if (!_isLiked) {
          _isLiked = await _userVideoStore.likeVideo(
            videoID: widget.videos[currentPos].videoId,
          );
          if (_isLiked) {
            likeCount += 1;
            print("liked");
          }
        } else {
          await _userVideoStore
              .dislikeVideo(
            videoID: widget.videos[currentPos].videoId,
          )
              .then((value) {
            if (value) {
              _isLiked = false;
            }
          });
          if (!_isLiked) {
            likeCount -= 1;
            print("disliked");
          }
        }
        _processing = false;
      }
      setup();
      setState(() {
        _isLiked != _isLiked;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;

    return Platform.isIOS
        ? PlayerIOS(
            controller: _controller,
            playing: playing,
            playerBody: listPlayerBody(),
          )
        : WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              key: _scaffoldGlobalKey,
              body: listPlayerBody(),
              // floatingActionButton:
              //     MediaQuery.of(context).orientation == Orientation.landscape
              //         ? Container()
              //         : FloatingActionButton(
              //             backgroundColor: AppTheme.secondaryColor,
              //             onPressed: () {
              //               playing ? _controller.pause() : _controller.play();
              //               playing = _controller.value.isPlaying;
              //               setState(() {});
              //             },
              //             child: Icon(
              //               playing ? Icons.pause : Icons.play_arrow,
              //               color: AppTheme.pureBlackColor,
              //             ),
              //           ),
              // floatingActionButtonLocation:
              //     FloatingActionButtonLocation.miniEndFloat,
            ),
          );
  }

  showUnmuteAudioTimer() {
    Timer(Duration(seconds: 1), () {
      setState(() {
        showMuteAudio = false;
      });
    });
  }

  updateVideo() {
    _controller.pause();
    playing = _controller.value.isPlaying;
    loading = true;
    _boolFutureCalled = false;
    setState(() {});
    mySetup();
  }

  currPos() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        return Text(
          value.position == null ? "" : trimDuration(value.position),
          style: TextStyle(
            color: AppTheme.pureWhiteColor,
            fontSize: 17.0,
          ),
        );
      },
    );
  }

  videoBody() {
    return GestureDetector(
      child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: _controller.value.initialized
              ? VideoPlayer(_controller)
              : CachedNetworkImage(
                  imageUrl: widget.videos[currentPos].thumbUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fitWidth),
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
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
    );
  }

  toggleOrientation() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      Platform.isAndroid
          ? SystemChrome.setPreferredOrientations(
              [DeviceOrientation.landscapeLeft])
          : SystemChrome.setPreferredOrientations(
              [DeviceOrientation.landscapeRight]);
      Platform.isAndroid ? SystemChrome.setEnabledSystemUIOverlays([]) : null;
    } else if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Platform.isAndroid
          ? SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.top, SystemUiOverlay.bottom])
          : null;
    } else {
      return;
    }
  }

  autoPlay() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        isPotrait = value.aspectRatio <= 0.5;
        if (value.position != value.duration) {
          return MediaQuery.of(context).orientation == Orientation.landscape
              ? SafeArea(
                  child: Container(
                    height: _size.height - _size.aspectRatio * 25,
                    width: _size.width - 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _size.aspectRatio - 0.3,
                          child: videoBody(),
                        ),
                        isPotrait
                            ? Container()
                            : Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.fullscreen,
                                      size: 30,
                                      color: AppTheme.pureWhiteColor,
                                    ),
                                    onPressed: () {
                                      toggleOrientation();
                                    },
                                  ),
                                ),
                              ),
                        //landscape
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 500),
                            opacity: showMuteAudio ? 1.0 : 0.0,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              child: Icon(Icons.volume_off),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: showUnmuteAudio ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 500),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              child: Icon(Icons.volume_up),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    videoBody(),
                    isPotrait
                        ? Container()
                        : Positioned(
                            bottom: 0.0,
                            right: 0.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.fullscreen,
                                size:
                                    widget.videos[currentPos].aspectRatio <= 0.6
                                        ? 0
                                        : 30,
                                color: AppTheme.pureWhiteColor,
                              ),
                              onPressed: () {
                                toggleOrientation();
                              },
                            ),
                          ),
                    //portrait videos
                    // Container(
                    //   width: 100,
                    //   height: 100,
                    //   color: Colors.white,
                    // ),
                    Align(
                        alignment: Alignment.center,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: showMuteAudio ? 1.0 : 0.0,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            child: Icon(Icons.volume_off),
                          ),
                        )),
                    Align(
                        alignment: Alignment.center,
                        child: AnimatedOpacity(
                          opacity: showUnmuteAudio ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            child: Icon(Icons.volume_up),
                          ),
                        ))
                  ],
                );
        } else {
          vidPageController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.ease);
          return Container();
        }
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

  GlobalKey pageKey = GlobalKey();

  videoProgressIndicator() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue val, child) {
        return _controller != null && _controller.value.duration != null
            ? Slider(
                min: 0.0,
                max: _controller.value.duration.inSeconds.toDouble(),
                value: val.position.inSeconds.toDouble(),
                onChanged: (pos) {
                  _controller.seekTo(Duration(seconds: pos.toInt()));
                },
                activeColor: AppTheme.secondaryColor,
                inactiveColor: AppTheme.primaryColor,
              )
            : LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: AppTheme.primaryColor,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
              );
      },
    );
  }

  Widget listPlayerBody() {
    vidPageController = PageController(initialPage: currentPos);
    return PageView(
      scrollDirection: Axis.vertical,
      key: pageKey,
      controller: vidPageController,
      onPageChanged: (index) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        currentPos = index;
        updateVideo();
      },
      children: widget.videos.map((e) {
        return GestureDetector(
          onTap: () {
            if (unmute) {
              Platform.isIOS
                  ? cupertinoSnackbar(context, "Audio Muted")
                  : _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 500),
                      content: Text('Audio Muted'),
                    ));
              setState(() {
                showMuteAudio = true;
                unmute = false;
              });
              _controller.setVolume(0.0);
              Timer(Duration(milliseconds: 1000), () {
                setState(() {
                  showMuteAudio = false;
                });
              });
            } else {
              Platform.isIOS
                  ? cupertinoSnackbar(context, "Audio Unmuted")
                  : _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 500),
                      content: Text('Audio Unmuted'),
                    ));

              print("unmuted");
              setState(() {
                showUnmuteAudio = true;
                unmute = true;
              });
              _controller.setVolume(1.0);
              Timer(Duration(milliseconds: 1000), () {
                setState(() {
                  showUnmuteAudio = false;
                });
              });
            }
          },
          onDoubleTap: () {
            _onLikedPressed();
          },
          child: Material(
            color: Colors.black,
            child: Stack(children: [
              OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape)
                    print('Orientation: landscape');
                  else
                    print('Orientation: Potrait');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        currentPos == widget.videos.length - 1
                            ? orientation == Orientation.landscape
                                ? SafeArea(
                                    child: Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: _size.aspectRatio,
                                          child: videoBody(),
                                        ),
                                        // _controller.value.aspectRatio <= 0.
                                        //     ? Container()
                                        //     :
                                        Positioned(
                                          bottom: 0.0,
                                          right: 0.0,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.fullscreen,
                                                size: 30,
                                                color: AppTheme.pureWhiteColor,
                                              ),
                                              onPressed: () {
                                                toggleOrientation();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Stack(children: [
                                    videoBody(),
                                    _controller.value.aspectRatio <= 1
                                        ? Container()
                                        : Positioned(
                                            bottom: 0.0,
                                            right: 0.0,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.fullscreen,
                                                size: 30,
                                                color: AppTheme.pureWhiteColor,
                                                //done
                                              ),
                                              onPressed: () {
                                                toggleOrientation();
                                              },
                                            )),
                                  ])
                            : autoPlay(),
                      ],
                    ),
                  );
                },
              ),
              OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape)
                    print('Orientation: landscape');
                  else
                    print('Orientation: Potrait');
                  return orientation == Orientation.landscape
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _controller.pause();
                                      playing = false;
                                      setState(() {});
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) {
                                            return SearchProfile(uid: _user.id);
                                          },
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(_user
                                                      .photoUrl ==
                                                  null
                                              ? "https://via.placeholder.com/150"
                                              : _user.photoUrl),
                                          radius: 13,
                                        ),
                                        Text(
                                          '  ${_user.username} \u2022',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (_userAuth.user == null) {
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) {
                                              return Authentication(
                                                  AuthIndex.REGISTER);
                                            },
                                          ),
                                        );
                                      } else {
                                        try {
                                          print(_following);
                                          _following =
                                              await _userInfoStore.followUser(
                                                  uid: widget.videos[currentPos]
                                                      .uploaderUid);
                                          print(_following);
                                          print('pressed');
                                          setState(() {});
                                        } on Exception catch (e) {
                                          print(e.toString());
                                        }
                                      }
                                    },
                                    child: Text(
                                      _userAuth.user == null
                                          ? "Follow"
                                          : _userAuth.user.uid ==
                                                  widget.videos[currentPos]
                                                      .uploaderUid
                                              ? ' '
                                              : !_following
                                                  ? ' Follow'
                                                  : " Following",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 23, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    widget.videos[currentPos].videoName != null
                                        ? widget.videos[currentPos].videoName
                                                    .length >
                                                37
                                            ? "Title" +
                                                ' \u2022 ' +
                                                getChoppedUsername(widget
                                                    .videos[currentPos]
                                                    .videoName)
                                            : "Title" +
                                                ' \u2022 ' +
                                                widget.videos[currentPos]
                                                    .videoName +
                                                ' \u2022 '
                                        : "Title" + ' \u2022 ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      widget.videos[currentPos].videoHashtag !=
                                              null
                                          ? widget.videos[currentPos]
                                                  .videoHashtag +
                                              ' \u2022 '
                                          : "\t",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Like, Comment and rate
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                              color: Colors.black12.withOpacity(0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Platform.isIOS
                                          ? CupertinoButton(
                                              child: SvgPicture.asset(
                                                _isLiked
                                                    ? "assets/images/loved_icon.svg"
                                                    : "assets/images/love_icon.svg",
                                                color: _isLiked
                                                    ? AppTheme.secondaryColor
                                                    : AppTheme
                                                        .secondaryColorDark,
                                                width: 20,
                                              ),
                                              onPressed: () async {
                                                if (_userAuth.user == null) {
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return Authentication(
                                                            AuthIndex.REGISTER);
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  if (!_processing) {
                                                    _processing = true;
                                                    if (!_isLiked) {
                                                      _isLiked =
                                                          await _userVideoStore
                                                              .likeVideo(
                                                        videoID: widget
                                                            .videos[currentPos]
                                                            .videoId,
                                                      );
                                                      if (_isLiked) {
                                                        likeCount += 1;
                                                        print("liked");
                                                      }
                                                    } else {
                                                      await _userVideoStore
                                                          .dislikeVideo(
                                                        videoID: widget
                                                            .videos[currentPos]
                                                            .videoId,
                                                      )
                                                          .then((value) {
                                                        if (value) {
                                                          _isLiked = false;
                                                        }
                                                      });
                                                      if (!_isLiked) {
                                                        likeCount -= 1;
                                                        print("disliked");
                                                      }
                                                    }
                                                    _processing = false;
                                                  }
                                                  setup();
                                                  setState(() {});
                                                }
                                              },
                                            )
                                          : InkWell(
                                              // child: SvgPicture.asset(
                                              //   _isLiked
                                              //       ? "assets/images/loved_icon.svg"
                                              //       : "assets/images/love_icon.svg",
                                              //   color: _isLiked
                                              //       ? AppTheme.secondaryColor
                                              //       : AppTheme
                                              //           .secondaryColorDark,
                                              //   width: 20,
                                              child: _isLiked
                                                  ? Icon(Icons.favorite,
                                                      color: Colors.red)
                                                  : Icon(
                                                      Icons
                                                          .favorite_outline_rounded,
                                                      color: Colors.white),
                                              onTap: () async {
                                                _onLikedPressed();
                                              },
                                            ),
                                      SizedBox(
                                        width: _widthOne * 20,
                                      ),
                                      Text(
                                        likeCount.toString() == "null"
                                            ? "0"
                                            : likeCount.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: _fontOne * 14,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: _widthOne * 30,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Platform.isIOS
                                          ? CupertinoButton(
                                              onPressed: () {
                                                if (_userAuth.user == null) {
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return Authentication(
                                                            AuthIndex.REGISTER);
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  print(widget
                                                      .videos[currentPos]
                                                      .uploaderUid);
                                                  _controller.pause();
                                                  playing = false;
                                                  setState(() {});
                                                  SystemChrome
                                                      .setPreferredOrientations([
                                                    DeviceOrientation.portraitUp
                                                  ]);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CommentsScreen(
                                                                videoId: widget
                                                                    .videos[
                                                                        currentPos]
                                                                    .videoId,
                                                              )));
                                                }
                                              },
                                              child: Icon(
                                                Icons.comment,
                                                color: Colors.white,
                                                size: _iconOne * 23,
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                if (_userAuth.user == null) {
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return Authentication(
                                                            AuthIndex.REGISTER);
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  print(widget
                                                      .videos[currentPos]
                                                      .uploaderUid);
                                                  _controller.pause();
                                                  playing = false;
                                                  setState(() {});
                                                  SystemChrome
                                                      .setPreferredOrientations([
                                                    DeviceOrientation.portraitUp
                                                  ]);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CommentsScreen(
                                                        videoId: widget
                                                            .videos[currentPos]
                                                            .videoId,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.mode_comment_outlined,
                                                color: Colors.white,
                                                size: _iconOne * 23,
                                              ),
                                            ),
                                      SizedBox(
                                        width: _widthOne * 20,
                                      ),
                                      FutureBuilder(
                                        future: _userVideoStore.getComments(
                                            id: widget
                                                .videos[currentPos].videoId),
                                        builder: (context, snap) {
                                          if (snap.data == null) {
                                            return Text(
                                              widget.videos[currentPos].comments
                                                          .toString() ==
                                                      null
                                                  ? "0"
                                                  : widget.videos[currentPos]
                                                      .comments
                                                      .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: _fontOne * 14,
                                                  color: Colors.white),
                                            );
                                          }
                                          return Text(
                                            snap.data.docs.length == null
                                                ? "0"
                                                : snap.data.docs.length
                                                    .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: _fontOne * 14,
                                                color: Colors.white),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: _widthOne * 60,
                                  ),
                                  SizedBox(
                                    width: _widthOne * 550,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackShape: RoundSliderTrackShape(),
                                        trackHeight: 7.0,
                                        thumbColor: AppTheme.primaryColor,
                                        thumbShape: StarThumb(thumbRadius: 20),
                                        overlayColor: AppTheme.pureBlackColor,
                                        overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 30.0,
                                        ),
                                      ),
                                      child: RotatedBox(
                                        quarterTurns: 4,
                                        child: Slider(
                                          value: _sliderValue,
                                          min: 0,
                                          max: 5,
                                          onChangeEnd: (val) async {
                                            if (_userAuth.user == null) {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return Authentication(
                                                        AuthIndex.REGISTER);
                                                  },
                                                ),
                                              );
                                            } else {
                                              bool success =
                                                  await _userVideoStore
                                                      .rateVideo(
                                                          videoID: widget
                                                              .videos[
                                                                  currentPos]
                                                              .videoId,
                                                          newRating:
                                                              _sliderValue);
                                              if (!success) {
                                                setState(() {
                                                  _sliderValue = 0;
                                                });
                                              }
                                            }
                                          },
                                          onChanged: (val) async {
                                            setState(() {
                                              _sliderValue = val;
                                            });
                                          },
                                          inactiveColor: AppTheme.primaryColor,
                                          activeColor: AppTheme.secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Padding(
                            //   padding: EdgeInsets.only(left: 23),
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.equalizer,
                            //         color: Colors.white,
                            //       ),
                            //       Text(
                            //         ' \u2022 ' +
                            //                 widget.videos[currentPos]
                            //                     .category ??
                            //             "Category",
                            //         style: TextStyle(color: Colors.white),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  splashRadius: 0.1,
                                  onPressed: () {
                                    playing
                                        ? _controller.pause()
                                        : _controller.play();
                                    playing = _controller.value.isPlaying;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    playing ? Icons.pause : Icons.play_arrow,
                                    color: AppTheme.pureWhiteColor,
                                    size: 22.0,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 130,
                                  height: 8.0,
                                  child: videoProgressIndicator(),
                                ),
                                currPos(),
                              ],
                            ),
                            orientation == Orientation.landscape
                                ? Container()
                                : Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [],
                                    ),
                                  ),
                            SizedBox(height: 10.0),
                          ],
                        );
                },
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
  }
}
