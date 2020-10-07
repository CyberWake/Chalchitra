import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/profile/editProfileScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/followersScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/followingsScreen.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

import '../../../model/theme.dart';

class ProfilePage extends StatefulWidget {
  final String url =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final String uid;

  ProfilePage({@required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Fetching user attributes from the user model

  UserDataModel user;
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _userAuth = UserAuth();
  // Attributes

  bool loading = false;
  String profileUid;
  String _username;
  String currentUserID;
  int totalFollowers = 0;
  int totalFollowings = 0;
  int totalPost = 0;
  bool following = false;
  bool isSecure = false;
  bool seeFollowers = false;
  bool seeFollowings = false;
  String currentUserImgUrl;
  String currentUserName;

  //user video posts parameters
  final thumbWidth = 100;
  final thumbHeight = 150;

  List<VideoInfo> _videos = <VideoInfo>[];
  List<VideoInfo> newVideos = <VideoInfo>[];

  void setup() async {
    dynamic result = await UserVideoStore().getProfileVideos(uid: profileUid);
    if (result != false) {
      setState(() {
        _videos = result;
      });
    }
  }

  void getPrivacy() async {
    isSecure = await _userInfoStore.getPrivacy(uid: widget.uid);
    if (!isSecure) {
      print("private " + isSecure.toString());
      setup();
      setState(() {
        seeFollowers = true;
        seeFollowings = true;
      });
    } else if (widget.uid == _userAuth.user.uid) {
      setState(() {
        seeFollowers = true;
        seeFollowings = true;
      });
    }
  }

  void mySuper() async {
    await getCurrentUserID();
    await checkIfAlreadyFollowing();
    profileUid = widget.uid;
    print("following " + following.toString());
    if (following || widget.uid == _userAuth.user.uid) {
      print("called a");
      setup();
      getPrivacy();
    } else {
      getPrivacy();
    }
  }

  @override
  void initState() {
    super.initState();
    mySuper();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Container(
      color: AppTheme.elevationColor,
      child: Column(
        children: [
          Stack(
            children: [
              getProfileTopView(context),
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(0.0, -10.0), //(x,y)
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  height: size.height * 0.4423,
                  width: size.width,
                  margin: EdgeInsets.only(top: size.height * 0.35),
                  padding: EdgeInsets.only(
                      top: size.height * 0.1,
                      left: size.width * 0.05,
                      right: size.width * 0.05),
                  child: buildPictureCard(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(top: size.height * 0.16),
                    width: size.width * 0.9,
                    child: Card(
                      elevation: 20,
                      color: Colors.yellow[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            user != null
                                ? Text(
                                    user.bio,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.elevationColor,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Container(),
                            SizedBox(
                              height: 15,
                            ),
                            createButton(),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(_videos.length, "Posts"),
                                getFollowers(),
                                getFollowings()
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }

  getFollowers() {
    return StreamBuilder(
        stream: _userInfoStore.getFollowers(uid: widget.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return GestureDetector(
            onTap: () {
              if (seeFollowers) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            FollowersPage(uid: widget.uid)));
              }
            },
            child: Column(
              children: [
                Text(
                  !snapshot.hasData
                      ? "0"
                      : snapshot.data.documents.length.toString(),
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.elevationColor),
                ),
                Text(
                  'Followers',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.elevationColor),
                ),
              ],
            ),
          );
        });
  }

  getFollowings() {
    return new StreamBuilder(
        stream: _userInfoStore.getFollowing(uid: widget.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return GestureDetector(
            onTap: () {
              if (seeFollowings) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            FollowingsPage(uid: widget.uid)));
              }
            },
            child: Column(
              children: [
                Text(
                  !snapshot.hasData
                      ? "0"
                      : snapshot.data.documents.length.toString(),
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.elevationColor),
                ),
                Text(
                  'Following',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.elevationColor),
                ),
              ],
            ),
          );
        });
  }

  checkIfAlreadyFollowing() async {
    bool result = await _userInfoStore.checkIfAlreadyFollowing(uid: widget.uid);
    setState(() {
      following = result;
    });
  }

  controlFollowUsers() async {
    bool result = await _userInfoStore.followUser(uid: widget.uid);
    mySuper();
    setState(() {
      following = result;
    });
  }

  controlUnFollowUsers() async {
    bool result = await _userInfoStore.unFollowUser(uid: widget.uid);
    _videos = [];
    getPrivacy();
    setState(() {
      following = result;
    });
  }

  getCurrentUserID() {
    final User firebaseUser = UserAuth().user;
    String uid = firebaseUser.uid;
    String url = firebaseUser.photoURL;
    String displayName = firebaseUser.displayName;
    setState(() {
      currentUserID = uid;
      currentUserImgUrl = url;
      currentUserName = displayName;
    });
  }

  String getChoppedUsername(String currentDisplayName) {
    String choppedUsername = '';
    var subDisplayName = currentDisplayName.split(' ');
    for (var i in subDisplayName) {
      if (choppedUsername.length + i.length < 18) {
        choppedUsername += ' ' + i;
      } else {
        return choppedUsername;
      }
    }
    return choppedUsername;
  }

  getProfileTopView(BuildContext context) {
    return new StreamBuilder<DocumentSnapshot>(
        stream: _userInfoStore.getUserInfoStream(uid: widget.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitCircle(
                color: AppTheme.primaryColor,
                size: 60,
              ),
            );
          }
          print(snapshot.data.exists);
          user = UserDataModel.fromDocument(snapshot.data);

          _username = user.username;

          return Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  offset: Offset(0.0, 20.0), //(x,y)
                  blurRadius: 10.0,
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: widget.url,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            user.photoUrl != null ? user.photoUrl : widget.url),
                        radius: 40,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            child: Text(
                              user.displayName != null
                                  ? user.displayName.length > 19
                                      ? getChoppedUsername(user.displayName)
                                      : user.displayName
                                  : "WowTalent",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.pureWhiteColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                '$_username',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          );
        });
  }

  createButton() {
    bool userProfile = currentUserID == widget.uid;
    if (userProfile) {
      return createButtonTitleORFunction(
          title: 'Edit Profile', function: gotoEditProfile);
    } else if (following) {
      return createButtonTitleORFunction(
          title: 'Unfollow', function: controlUnFollowUsers);
    } else if (!following) {
      return createButtonTitleORFunction(
          title: 'Follow', function: controlFollowUsers);
    }
  }

  gotoEditProfile() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => EditProfilePage(
                  uid: currentUserID,
                )));
  }

  Container createButtonTitleORFunction({String title, Function function}) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Platform.isIOS
            ? CupertinoButton(
                borderRadius: BorderRadius.circular(30),
                color: AppTheme.primaryColor,
                onPressed: () async {
                  await function();
                  await getFollowers();
                  setState(() {});
                },
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
              )
            : RaisedButton(
                color: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                onPressed: () async {
                  await function();
                  await getFollowers();
                  setState(() {});
                },
                child: Container(
                  width: 150,
                  height: 30,
                  child: Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.elevationColor,
                          fontSize: 16)),
                  alignment: Alignment.center,
                )));
  }

  SingleChildScrollView buildPictureCard() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 1,
            runSpacing: 1,
            children: List.generate(_videos.length, (index) {
              final video = _videos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    Platform.isIOS
                        ? CupertinoPageRoute(
                            builder: (context) => Player(
                                  video: video,
                                ))
                        : MaterialPageRoute(
                            builder: (context) {
                              return Player(
                                video: video,
                              );
                            },
                          ),
                  );
                },
                child: Container(
                  width: size.width * 0.22,
                  height: size.height * 0.22,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                        image: NetworkImage(video.thumbUrl),
                        fit: BoxFit.fitWidth),
                    borderRadius: BorderRadius.circular(10.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0.0, 10.0), //(x,y)
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Column buildStatColumn(int value, String title) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.elevationColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.elevationColor,
          ),
        ),
      ],
    );
  }
}
