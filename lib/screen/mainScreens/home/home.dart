import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/home/postCard.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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

  ParticleOptions particleOptions = ParticleOptions(
    image: Image.asset('assets/images/star_stroke.png'),
    baseColor: Colors.blue,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.1,
    maxOpacity: 0.4,
    spawnMinSpeed: 30.0,
    spawnMaxSpeed: 70.0,
    spawnMinRadius: 7.0,
    spawnMaxRadius: 15.0,
    particleCount: 40,
  );

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

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
            return ListView.builder(
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              highlightColor: AppTheme.pureWhiteColor,
                              baseColor: AppTheme.backgroundColor,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: _widthOne * 140,
                                    height: _heightOne * 40,
                                    decoration: BoxDecoration(
                                        color: AppTheme.backgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  SizedBox(
                                    width: _widthOne * 40,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: _heightOne * 20,
                                          width: _widthOne * 300,
                                          color: AppTheme.backgroundColor,
                                        ),
                                        SizedBox(
                                          height: _heightOne * 1.5,
                                        ),
                                        Container(
                                          height: _heightOne * 20,
                                          width: _widthOne * 250,
                                          color: AppTheme.backgroundColor,
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
                                      Icon(Icons.more_horiz,
                                          color: Colors.grey,
                                          size: _iconOne * 30),
                                      Container(
                                        height: _heightOne * 15,
                                        width: _widthOne * 100,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: _heightOne * 15,
                            ),
                            Expanded(
                              child: Shimmer.fromColors(
                                highlightColor: AppTheme.pureWhiteColor,
                                baseColor: AppTheme.backgroundColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        offset: Offset(0.0, 0.0), //(x,y)
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: _heightOne * 15,
                            ),
                            Shimmer.fromColors(
                              highlightColor: AppTheme.pureWhiteColor,
                              baseColor: AppTheme.backgroundColor,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: _heightOne * 35,
                                width: double.infinity,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            if (data.data.documents.length == 0) {
              return Container(
                color: Platform.isIOS
                    ? AppTheme.backgroundColor
                    : Colors.transparent,
                child: AnimatedBackground(
                  behaviour: RandomParticleBehaviour(
                    options: particleOptions,
                    paint: particlePaint,
                  ),
                  vsync: this,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(text: '', children: <InlineSpan>[
                            TextSpan(
                              text: 'Follow',
                              style: TextStyle(
                                  fontSize: 56,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '  Creators to see content',
                              style: TextStyle(
                                  fontSize: 38,
                                  color: AppTheme.pureWhiteColor,
                                  fontWeight: FontWeight.bold),
                            )
                          ])),
                          SizedBox(height: 20),
                          FlatButton(
                            color: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => MainScreenWrapper(
                                            index: 1,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2),
                              child: Text(
                                'Explore Content',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.pureWhiteColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
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
                        return Center(
                          child: SpinKitCircle(
                            color: AppTheme.backgroundColor,
                            size: 60,
                          ),
                        );
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
                              return delTop < (0.2 * viewPort) &&
                                  delBottom > (0.2 * viewPort);
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
