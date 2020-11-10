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
  UserInfoStore _userInfoStore = UserInfoStore();
  List _usersDetails = [];
  PopupMenu menu;
  GlobalKey btnKey = GlobalKey();
  UserAuth _userAuth = UserAuth();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return FutureBuilder(
        future: _userInfoStore.getFollowingFuture(uid: _userAuth.user.uid),
        builder: (context, data) {
          if (!data.hasData ||
              data.connectionState == ConnectionState.waiting) {
            return DummyPostCard();
          } else {
            if (data.data.documents.length == 0) {
              return NoDataTile(
                showButton: true,
                isActivity: false,
                titleText: "Follow",
                bodyText: "  Creators to see content",
                buttonText: "Explore Talent",
              );
            } else {
              return RefreshIndicator(
                backgroundColor: AppTheme.primaryColor,
                color: AppTheme.backgroundColor,
                onRefresh: () async {
                  UserVideoStore()
                      .getFollowingVideos(followings: data.data.documents);
                  setState(() {});
                },
                child: FutureBuilder(
                    future: UserVideoStore()
                        .getFollowingVideos(followings: data.data.documents),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DummyPostCard();
                      } else {
                        List<VideoInfo> videoList = [];
                        snapshot.data.documents.forEach(
                            (ds) => videoList.add(VideoInfo.fromDocument(ds)));
                        if (snapshot.data.documents.length == 0) {
                          return Container(
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
                          );
                        } else {
                          return Center(
                              child: InViewNotifierList(
                            isInViewPortCondition: (double delTop,
                                double delBottom, double viewPort) {
                              return delTop < (0.5 * viewPort) &&
                                  delBottom > (0.5 * viewPort);
                            },
                            itemCount: snapshot.data.documents.length,
                            builder: (context, index) {
                              return FutureBuilder(
                                future: _userInfoStore.getUserInfo(
                                    uid: snapshot.data.documents[index]
                                        .data()['uploaderUid']),
                                builder: (context, snap) {
                                  if (snap.connectionState ==
                                          ConnectionState.none ||
                                      !snap.hasData) {
                                    return Container();
                                  } else if (snap.connectionState ==
                                      ConnectionState.done) {
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
                                            uploader:
                                                snap.data.data()['username'],
                                            profileImg: snap.data
                                                        .data()['photoUrl'] ==
                                                    null
                                                ? "https://via.placeholder.com/150"
                                                : snap.data.data()['photoUrl'],
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
                                  }
                                  return Container();
                                },
                              );
                            },
                          ));
                        }
                      }
                    }),
              );
            }
          }
        });
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
