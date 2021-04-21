import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/home/postCard.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
import 'package:wowtalent/widgets/dummyPostCard.dart';
import 'package:wowtalent/widgets/noDataTile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<VideoInfo> _videos = <VideoInfo>[];
  double _widthOne;
  double _heightOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  bool loading = true;
  UserInfoStore _userInfoStore = UserInfoStore();
  List _usersDetails = [];
  PopupMenu menu;
  GlobalKey btnKey = GlobalKey();
  UserAuth _userAuth = UserAuth();

  List<DocumentSnapshot> followingFuture = [];
  List<VideoInfo> videoList = [];
  List userInfo = [];
  setup() async {
    try {
      await _userInfoStore
          .getFollowingFuture(uid: _userAuth.user.uid)
          .then((value) {
        value.docs.forEach((e) {
          followingFuture.add(e);
        });
      });
      if (followingFuture.length != 0) {
        print("running");
        await UserVideoStore()
            .getFollowingVideos(followings: followingFuture)
            .then((value) {
          value.docs.forEach((e) async {
            VideoInfo vid = VideoInfo.fromDocument(e);
            videoList.add(vid);
          });
        });
      }
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  fetchUserList() async {
    try {
      await Future.forEach(videoList, (element) async {
        await _userInfoStore.getUserInfo(uid: element.uploaderUid).then((val) {
          userInfo.add(UserDataModel.fromDocument(val));
        });
      });
      return true;
    } catch (e) {}
  }

  Future onRefresh() async {
    setState(() {
      loading = true;
      followingFuture = [];
      videoList = [];
      userInfo = [];
    });
    await setup().then((v) {
      if (v) {
        fetchUserList().then((res) {
          if (res) {
            setState(() {
              loading = false;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    setup().then((v) {
      if (v) {
        fetchUserList().then((res) {
          if (res) {
            setState(() {
              loading = false;
            });
          }
        });
      }
    });
    super.initState();
  }

  Widget build(context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return !loading
        ? followingFuture.length == 0
            ? Container(
                color: Platform.isIOS
                    ? AppTheme.backgroundColor
                    : Colors.transparent,
                child: NoDataTile(
                  showButton: true,
                  isActivity: false,
                  titleText: "Follow",
                  bodyText: "  Creators to see content",
                  buttonText: "Explore Talent",
                ))
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: videoList.length == 0
                    ? Container(
                        color: AppTheme.backgroundColor,
                        child: Center(
                          child: Text(
                            "No videos to show",
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: InViewNotifierList(
                        isInViewPortCondition:
                            (double delTop, double delBottom, double viewPort) {
                          return delTop < (0.5 * viewPort) &&
                              delBottom > (0.5 * viewPort);
                        },
                        itemCount: videoList.length,
                        builder: (context, index) {
                          return InViewNotifierWidget(
                            id: videoList[index].videoId,
                            builder: (context, isInView, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: _widthOne * 50,
                                    vertical: _heightOne * 20),
                                child: PostCard(
                                  playVideo: isInView ? true : false,
                                  video: videoList[index],
                                  uploader: userInfo[index].username,
                                  profileImg: userInfo[index].photoUrl == null
                                      ? "https://via.placeholder.com/150"
                                      : userInfo[index].photoUrl,
                                  navigate: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Player(
                                            videos: videoList,
                                            index: index,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      )))
        : DummyPostCard();
  }

  void getUsersDetails() async {
    for (int i = 0; i < _videos.length; i++) {
      print("vid" + _videos[i].uploaderUid.toString());
      dynamic result =
          await _userInfoStore.getUserInfo(uid: _videos[i].uploaderUid);
      print(result.data());
      if (result != null) {
        _usersDetails.add(UserDataModel.fromDocument(result));
      } else {
        _usersDetails.add(null);
      }
    }

    setState(() {});
  }
}
