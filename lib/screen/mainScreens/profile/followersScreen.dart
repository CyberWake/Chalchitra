import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/ios_Screens/profile/followersScreenIOS.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';

class FollowersPage extends StatefulWidget {
  final String uid;
  FollowersPage({this.uid});
  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage>
    with TickerProviderStateMixin {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _userAuth = UserAuth();
  String nullImageUrl =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final _followerListKey = GlobalKey();
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
  Size _size;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Platform.isIOS
        ? FollowersScreenIOS(followersBody: followersBody(),)
        : Scaffold(
            key: _scaffoldGlobalKey,
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text('Followers'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: followersBody(),
          );
  }

  Widget followersBody(){
    return StreamBuilder(
        stream: _userInfoStore.getFollowers(uid: widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitCircle(
                color: AppTheme.primaryColor,
                size: 60,
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text('Something went wrong'));
          } else if (snapshot.data.documents.length == 0) {
            return Container(
                color: Colors.transparent,
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
                            Text.rich(TextSpan(
                                text: '',
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: 'Nice Content',
                                    style: TextStyle(
                                        fontSize: 56,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '  Attracts followers',
                                    style: TextStyle(
                                        fontSize: 38,
                                        color: AppTheme.pureWhiteColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ])),
                          ],
                        ),
                      ),
                    )));
          }
          return ListView.builder(
            key: _followerListKey,
            itemCount: snapshot.data.documents.length,
            padding: EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder(
                  future: _userInfoStore.getUserInfo(
                      uid: snapshot.data.documents[index].id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.done) {
                      var _user = UserDataModel.fromDocument(snap.data);
                      if (widget.uid == _userAuth.user.uid) {
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          actions: <Widget>[
                            IconSlideAction(
                                caption: 'Show Profile',
                                color: AppTheme.primaryColor,
                                icon: Icons.account_circle,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder:
                                              (BuildContext context) =>
                                              SearchProfile(
                                                uid: _user.id,
                                              )));
                                }),
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                                caption: 'Remove',
                                color: Colors.deepOrangeAccent,
                                icon: Icons.delete,
                                onTap: () async {
                                  bool result = await _userInfoStore
                                      .removeFollowingUser(
                                      uid: _user.id);
                                  if (!result) { Platform.isIOS ? cupertinoSnackbar(_followerListKey.currentContext,"Removed User from Followers succesfully") :
                                    _scaffoldGlobalKey.currentState
                                        .showSnackBar(SnackBar(
                                        content: Text(
                                            'Removed user from followers successfully')));
                                  } else {
                                   Platform.isIOS ? cupertinoSnackbar(_followerListKey.currentContext, "Something Went Wrong") : _scaffoldGlobalKey.currentState
                                        .showSnackBar(SnackBar(
                                        content: Text(
                                            'Something went wrong')));
                                  }
                                })
                          ],
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 0.8),
                            color: AppTheme.elevationColor,
                            child:Platform.isIOS ? Material(child:ListTile(
                              tileColor: AppTheme.backgroundColor,
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigoAccent,
                                backgroundImage: _user.photoUrl == null
                                    ? NetworkImage(nullImageUrl)
                                    : NetworkImage(_user.photoUrl),
                                foregroundColor: Colors.white,
                              ),
                              title: Text( _user.displayName == null
                                  ? "Wow Talent User"
                                  : _user.displayName,
                                  style: TextStyle(
                                      color: AppTheme.primaryColor)),
                              subtitle: Text(_user.username,
                                  style: TextStyle(
                                      color: AppTheme.primaryColor)),
                            ),
                            ) : ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigoAccent,
                                backgroundImage: _user.photoUrl == null
                                    ? NetworkImage(nullImageUrl)
                                    : NetworkImage(_user.photoUrl),
                                foregroundColor: Colors.white,
                              ),
                              title: Text( _user.displayName == null
                                  ? "Wow Talent User"
                                  : _user.displayName,
                                  style: TextStyle(
                                      color: AppTheme.primaryColor)),
                              subtitle: Text(_user.username,
                                  style: TextStyle(
                                      color: AppTheme.primaryColor)),
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (BuildContext context) =>
                                      SearchProfile(
                                        uid: _user.id,
                                      )));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 0.8),
                          color: AppTheme.elevationColor,
                          child:Platform.isIOS ? Material(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigoAccent,
                                backgroundImage: _user.photoUrl == null
                                    ? NetworkImage(nullImageUrl)
                                    : NetworkImage(_user.photoUrl),
                                foregroundColor: Colors.white,
                              ),
                              title: Text(
                                  _user.displayName == null
                                      ? "Wow Talent User"
                                      : _user.displayName,
                                  style: TextStyle(
                                      color: AppTheme.primaryColor)),
                              subtitle: Text(_user.username,
                                  style: TextStyle(
                                      color: AppTheme.primaryColor)),
                            )
                          ) : ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigoAccent,
                              backgroundImage: _user.photoUrl == null
                                  ? NetworkImage(nullImageUrl)
                                  : NetworkImage(_user.photoUrl),
                              foregroundColor: Colors.white,
                            ),
                            title: Text(
                                _user.displayName == null
                                    ? "Wow Talent User"
                                    : _user.displayName,
                                style: TextStyle(
                                    color: AppTheme.primaryColor)),
                            subtitle: Text(_user.username,
                                style: TextStyle(
                                    color: AppTheme.primaryColor)),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  });
            },
          );
        });
  }
}
