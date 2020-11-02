import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:screen/screen.dart';
import 'package:swipe_stack/swipe_stack.dart';
import 'package:video_player/video_player.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';
import 'package:wowtalent/widgets/customSliderThumb.dart';

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
  UserDataModel _user = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  bool _boolFutureCalled = false;
  bool _following = false;
  bool _processing = false;
  bool showCaption = true;
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
    Screen.keepOn(true);
    mySetup();
    showCaptionTimer();
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

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldGlobalKey,
        body: listPlayerBody(),
        floatingActionButton:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? Container()
                : FloatingActionButton(
                    backgroundColor: AppTheme.selectorTileColor,
                    onPressed: () {
                      playing ? _controller.pause() : _controller.play();
                      playing = _controller.value.isPlaying;
                      setState(() {});
                    },
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: AppTheme.pureBlackColor,
                    ),
                  ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  showCaptionTimer() {
    Timer(Duration(seconds: 5), () {
      setState(() {
        showCaption = false;
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
          style: TextStyle(color: AppTheme.pureWhiteColor),
        );
      },
    );
  }

  videoBody() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showCaption = true;
        });
        showCaptionTimer();
        if (unmute) {
          _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text('Audio Muted'),
          ));
          unmute = false;
          _controller.setVolume(0.0);
        } else {
          _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text('Audio Unmuted'),
          ));
          print("unmuted");
          unmute = true;
          _controller.setVolume(1.0);
        }
      },
      child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: _controller.value.initialized
              ? VideoPlayer(_controller)
              : SpinKitCircle(
                  color: AppTheme.primaryColor,
                  size: 60,
                )),
    );
  }

  toggleOrientation() {
    if (MediaQuery.of(context).orientation == Orientation.portrait &&
        _controller.value.aspectRatio > 1) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
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
        bool isPotrait = value.aspectRatio <= 1;
        if (value.position != value.duration) {
          return MediaQuery.of(context).orientation == Orientation.landscape
              ? SafeArea(
                  child: Stack(children: [
                  AspectRatio(
                    aspectRatio: _size.aspectRatio,
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
                          ))
                ]))
              : Stack(children: [
                  videoBody(),
                  isPotrait
                      ? Container()
                      : Positioned(
                          bottom: 0.0,
                          right: 0.0,
                          child: IconButton(
                            icon: Icon(
                              Icons.fullscreen,
                              size: 30,
                              color: AppTheme.pureWhiteColor,
                            ),
                            onPressed: () {
                              toggleOrientation();
                            },
                          ))
                ]);
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

  Widget listPlayerBody() {
    vidPageController = PageController(initialPage: currentPos);
    return !loading
        ? Container(
            color: AppTheme.pureBlackColor,
            width: _size.width,
            height: _size.height,
            child: PageView(
              key: pageKey,
              scrollDirection: Axis.vertical,
              controller: vidPageController,
              onPageChanged: (index) {
                showCaption = true;
                showCaptionTimer();
                currentPos = index;
                updateVideo();
              },
              children: widget.videos.map((e) {
                return Material(
                  color: Colors.black,
                  child: Stack(children: [
                    OrientationBuilder(
                      builder: (context, orientation) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              currentPos == widget.videos.length - 1
                                  ? orientation == Orientation.landscape
                                      ? SafeArea(
                                          child: Stack(children: [
                                          AspectRatio(
                                            aspectRatio: _size.aspectRatio,
                                            child: videoBody(),
                                          ),
                                          _controller.value.aspectRatio <= 1
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
                                                        color: AppTheme
                                                            .pureWhiteColor,
                                                      ),
                                                      onPressed: () {
                                                        toggleOrientation();
                                                      },
                                                    ),
                                                  ))
                                        ]))
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
                                                      color: AppTheme
                                                          .pureWhiteColor,
                                                    ),
                                                    onPressed: () {
                                                      toggleOrientation();
                                                    },
                                                  ))
                                        ])
                                  : autoPlay(),
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                    playedColor: AppTheme.selectorTileColor,
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.white),
                              ),
                              orientation == Orientation.landscape
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          currPos(),
                                          Text(
                                            _controller.value.duration == null
                                                ? ""
                                                : trimDuration(
                                                    _controller.value.duration),
                                            style: TextStyle(
                                                color: AppTheme.pureWhiteColor),
                                          )
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                    OrientationBuilder(builder: (context, orientation) {
                      return orientation == Orientation.landscape
                          ? Container()
                          : showCaption
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.75,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _controller.pause();

                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) {
                                                    return SearchProfile(
                                                        uid: _user.id);
                                                  },
                                                ),
                                              );
                                            },
                                            child: Row(children: [
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
                                            ]),
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
                                                      await _userInfoStore
                                                          .followUser(
                                                              uid: widget
                                                                  .videos[
                                                                      currentPos]
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
                                                          widget
                                                              .videos[
                                                                  currentPos]
                                                              .uploaderUid
                                                      ? ' '
                                                      : !_following
                                                          ? ' Follow'
                                                          : " Following",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 23, vertical: 4),
                                        child: Text(
                                          widget.videos[currentPos].videoName !=
                                                  null
                                              ? widget.videos[currentPos]
                                                          .videoName.length >
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
                                        )),
                                    Padding(
                                      padding: EdgeInsets.only(left: 23),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.equalizer,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            ' \u2022 ' +
                                                    widget.videos[currentPos]
                                                        .category ??
                                                "Category",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black12.withOpacity(0.4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                  child: SvgPicture.asset(
                                                    _isLiked
                                                        ? "assets/images/loved_icon.svg"
                                                        : "assets/images/love_icon.svg",
                                                    color: _isLiked
                                                        ? AppTheme
                                                            .selectorTileColor
                                                        : AppTheme
                                                            .selectorTileColor,
                                                    width: 20,
                                                  ),
                                                  onTap: () async {
                                                    if (_userAuth.user ==
                                                        null) {
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return Authentication(
                                                                AuthIndex
                                                                    .REGISTER);
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
                                                                .videos[
                                                                    currentPos]
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
                                                                .videos[
                                                                    currentPos]
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
                                                  }),
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
                                              IconButton(
                                                onPressed: () {
                                                  if (_userAuth.user == null) {
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return Authentication(
                                                              AuthIndex
                                                                  .REGISTER);
                                                        },
                                                      ),
                                                    );
                                                  } else {
                                                    print(widget
                                                        .videos[currentPos]
                                                        .uploaderUid);
                                                    _controller.pause();
                                                    SystemChrome
                                                        .setPreferredOrientations([
                                                      DeviceOrientation
                                                          .portraitUp
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
                                                icon: Icon(
                                                  Icons.comment,
                                                  color: Colors.white,
                                                  size: _iconOne * 23,
                                                ),
                                              ),
                                              SizedBox(
                                                width: _widthOne * 20,
                                              ),
                                              FutureBuilder(
                                                future:
                                                    _userVideoStore.getComments(
                                                        id: widget
                                                            .videos[currentPos]
                                                            .videoId),
                                                builder: (context, snap) {
                                                  if (snap.data == null) {
                                                    return Text(
                                                      widget.videos[currentPos]
                                                                  .comments
                                                                  .toString() ==
                                                              null
                                                          ? "0"
                                                          : widget
                                                              .videos[
                                                                  currentPos]
                                                              .comments
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize:
                                                              _fontOne * 14,
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  return Text(
                                                    snap.data.docs.length ==
                                                            null
                                                        ? "0"
                                                        : snap.data.docs.length
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: _fontOne * 14,
                                                        color: Colors.white),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: _widthOne * 30,
                                          ),
                                          SizedBox(
                                            width: _widthOne * 650,
                                            child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                trackShape:
                                                    RectangularSliderTrackShape(),
                                                trackHeight: 2.0,
                                                thumbColor:
                                                    AppTheme.primaryColor,
                                                thumbShape:
                                                    StarThumb(thumbRadius: 20),
                                                overlayColor:
                                                    AppTheme.pureBlackColor,
                                                overlayShape:
                                                    RoundSliderOverlayShape(
                                                        overlayRadius: 30.0),
                                              ),
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
                                                              AuthIndex
                                                                  .REGISTER);
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
                                                                rating:
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
                                                inactiveColor:
                                                    AppTheme.backgroundColor,
                                                activeColor:
                                                    AppTheme.selectorTileColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 35,
                                    )
                                  ],
                                )
                              : Container();
                    }),
                  ]),
                );
              }).toList(),
            ))
        : Center(
            child: Container(
            child: SpinKitCircle(
              color: AppTheme.primaryColor,
              size: 60,
            ),
          ));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
  }
}
