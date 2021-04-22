import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';

class FollowingsPage extends StatefulWidget {
  final String uid;
  FollowingsPage({this.uid});
  @override
  _FollowingsPageState createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage>
    with TickerProviderStateMixin {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _userAuth = UserAuth();
  String nullImageUrl =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final _listKey = GlobalKey();
  ParticleOptions particleOptions = ParticleOptions(
    image: Image.asset('assets/images/star_stroke.png'),
    baseColor: Colors.blue,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.1,
    maxOpacity: 0.4,
    spawnMinSpeed: 30.0,
    spawnMaxSpeed: 70.0,
    spawnMinRadius: 15.0,
    spawnMaxRadius: 25.0,
    particleCount: 40,
  );

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Platform.isIOS
        ? FollowingScreenIOS(
            followingBody: followingBody(),
          )
        : Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text('Following'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: followingBody(),
          );
  }

  Widget followingBody() {
    return StreamBuilder(
        stream: _userInfoStore.getFollowing(uid: widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCards();
          } else if (snapshot.data.documents.length == 0) {
            return NoDataTile(
              showButton: false,
              isActivity: false,
              titleText: "Follow",
              bodyText: "  Creators to see them here",
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder(
                    future: _userInfoStore.getUserInfo(
                        uid: snapshot.data.documents[index].id),
                    builder: (context, snap) {
                      if (!snap.hasData ||
                          snap.connectionState == ConnectionState.waiting) {
                        return LoadingCards();
                      } else if (snap.connectionState == ConnectionState.done) {
                        var _user = UserDataModel.fromDocument(snap.data);
                        return Container(
                          child: OpenContainer(
                            closedElevation: 0.0,
                            closedColor: AppTheme.backgroundColor,
                            transitionDuration: Duration(milliseconds: 500),
                            openBuilder: (BuildContext context,
                                void Function({Object returnValue}) action) {
                              return SearchProfile(
                                uid: _user.id,
                              );
                            },
                            closedBuilder:
                                (BuildContext context, void Function() action) {
                              return Container(
                                  margin: EdgeInsets.symmetric(vertical: 0.8),
                                  color: Colors.white,
                                  child: Platform.isIOS
                                      ? Material(
                                          child: profileTile(_user),
                                        )
                                      : profileTile(_user));
                            },
                          ),
                        );
                      } else {
                        return Container();
                      }
                    });
              },
            );
          }
        });
  }

  Widget profileTile(UserDataModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor,
        backgroundImage: user.photoUrl == null
            ? NetworkImage(nullImageUrl)
            : NetworkImage(user.photoUrl),
        foregroundColor: Colors.white,
      ),
      title: Text(
          user.displayName == null ? "Wow Talent User" : user.displayName,
          style: TextStyle(color: AppTheme.primaryColor)),
      subtitle:
          Text(user.username, style: TextStyle(color: AppTheme.primaryColor)),
    );
  }
}
