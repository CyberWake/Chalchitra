import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/common/formatTimeStamp.dart';
import 'package:wowtalent/screen/mainScreens/home/postCard.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';
import 'dart:io' show Platform;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<VideoInfo> _videos = <VideoInfo>[];
  double _widthOne;
  double _heightOne;
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
    Size size = MediaQuery.of(context).size;
    _widthOne = size.width * 0.0008;
    _heightOne = (size.height * 0.007) / 5;
    return StreamBuilder(
        stream: _userInfoStore.getFollowing(uid: _userAuth.user.uid),
        builder: (context, data) {
          if (!data.hasData) {
            return Center(
              child: SpinKitCircle(
                color: Colors.orange,
                size: 60,
              ),
            );
          } else {
            if (data.data.documents.length == 0) {
              return AnimatedBackground(
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
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ])),
                        SizedBox(height: 20),
                        Platform.isIOS
                            ? CupertinoButton.filled(
                                child: Text(
                                  'Explore Content',
                                  style: TextStyle(fontSize: 18),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (_) => MainScreenWrapper(
                                                index: 1,
                                              )));
                                },
                              )
                            : FlatButton(
                                color: Colors.orange,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10.0,horizontal: 2.0),
                                  child: Text(
                                    'Explore Content',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return FutureBuilder(
                  future: UserVideoStore()
                      .getFollowingVideos(followings: data.data.documents)
                      .first,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SpinKitCircle(
                          color: Colors.orange,
                          size: 60,
                        ),
                      );
                    } else {
                      if (snapshot.data.documents.length == 0) {
                        return Center(
                          child: Text(
                            "No videos to show",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder(
                              future: _userInfoStore.getUserInfo(
                                  uid: snapshot.data.documents[index]
                                      .data()['uploaderUid']),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                        ConnectionState.none ||
                                    !snap.hasData) {
                                  return Container();
                                }
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: _widthOne * 50,
                                      vertical: _heightOne * 20),
                                  child: PostCard(
                                      video: snapshot.data.documents[index],
                                      id: snapshot.data.documents[index].id,
                                      thumbnail: snapshot.data.documents[index]
                                          .data()['thumbUrl'],
                                      profileImg:
                                          snap.data.data()['photoUrl'] == null
                                              ? "https://via.placeholder.com/150"
                                              : snap.data.data()['photoUrl'],
                                      title: snapshot.data.documents[index]
                                          .data()['videoName'],
                                      uploader: snap.data.data()['username'],
                                      likeCount: snapshot.data.documents[index]
                                          .data()['likes'],
                                      commentCount: snapshot.data.documents[index]
                                          .data()['comments'],
                                      uploadTime: formatDateTime(
                                          millisecondsSinceEpoch: snapshot
                                              .data.documents[index]
                                              .data()['uploadedAt']),
                                      viewCount: snapshot.data.documents[index]
                                          .data()['views'],
                                      rating: snapshot.data.documents[index].data()['rating']),
                                );
                              },
                            );
                          },
                        ));
                      }
                    }
                  });
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
