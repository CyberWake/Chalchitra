import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/profile/editProfileScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/followersScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/followingsScreen.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

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
  bool following = false;
  bool isSecure = false;
  bool seeFollowers = false;
  bool seeFollowings = false;
  bool refreshVideos = false;

  //UserData
  String currentUserID;
  String currentUserImgUrl;
  String currentUserDisplayName;
  String currentUserUsername;
  String currentUserBio;
  int totalFollowers = 0;
  int totalFollowings = 0;
  int totalPost = 0;

  //user video posts parameters
  final thumbWidth = 100;
  final thumbHeight = 150;

  List<VideoInfo> _videos = <VideoInfo>[];

  void setup() async {
    dynamic result = await UserVideoStore().getProfileVideos(uid: widget.uid);
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

  checkIfAlreadyFollowing() async {
    bool result = await _userInfoStore.checkIfAlreadyFollowing(uid: widget.uid);
    setState(() {
      following = result;
    });
  }

  getSearchUserData() async {
    user = await _userInfoStore.getUserInformation(uid: widget.uid);
    totalFollowings = user.following;
    totalFollowers = user.followers;
    totalPost = user.videoCount;
    currentUserDisplayName = user.displayName;
    currentUserUsername = user.username;
    currentUserBio = user.bio;
    currentUserImgUrl = user.photoUrl;
    setState(() {});
  }

  void mySuper() async {
    await getSearchUserData();
    await checkIfAlreadyFollowing();
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
    if (widget.uid != _userAuth.user.uid) {
      mySuper();
    } else {
      setup();
      getPrivacy();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uid == _userAuth.user.uid) {
      user = Provider.of<CurrentUser>(context, listen: true).currentUserData;
      print("inside provider in profile");
      currentUserID = user.id;
      totalFollowings = user.following;
      totalFollowers = user.followers;
      totalPost = user.videoCount;
      currentUserDisplayName = user.displayName;
      currentUserUsername = user.username;
      currentUserBio = user.bio;
      currentUserImgUrl = user.photoUrl;
      print("totalFollowings: $totalFollowings");
    }
    Size size = MediaQuery.of(context).size;
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          Stack(
            children: [
              getProfileTopView(context),
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backColor,
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
                                    currentUserBio == null
                                        ? " Hello World!"
                                        : currentUserBio,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.pureBlackColor,
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
                                buildPostStat(),
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
    );
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backColor,
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  child: CachedNetworkImage(
                    imageUrl:
                        currentUserImgUrl != null ? user.photoUrl : widget.url,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
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
                        currentUserDisplayName != null
                            ? currentUserDisplayName.length > 19
                                ? getChoppedUsername(currentUserDisplayName)
                                : currentUserDisplayName
                            : "WowTalent",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.backgroundColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          currentUserUsername == null
                              ? "Hello World!"
                              : currentUserUsername,
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
  }

  createButton() {
    bool userProfile = currentUserID == widget.uid;
    print("$currentUserID : ${widget.uid}");
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

  controlUnFollowUsers() async {
    bool result = await _userInfoStore.unFollowUser(uid: widget.uid);
    if (!result) {
      user = await _userInfoStore.getUserInformation(uid: _userAuth.user.uid);
      Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
      totalFollowers -= 1;
    }
    _videos = [];
    getPrivacy();
    setState(() {
      following = result;
    });
  }

  controlFollowUsers() async {
    bool result = await _userInfoStore.followUser(uid: widget.uid);
    if (result) {
      user = await _userInfoStore.getUserInformation(uid: _userAuth.user.uid);
      Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
      totalFollowers += 1;
    }
    mySuper();
    setState(() {
      following = result;
    });
  }

  Container createButtonTitleORFunction({String title, Function function}) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: RaisedButton(
            color: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            onPressed: () async {
              await function();
              setState(() {});
            },
            child: Container(
              width: 150,
              height: 30,
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.backgroundColor,
                      fontSize: 16)),
              alignment: Alignment.center,
            )));
  }

  removeVideoFromUserAccount(int index) async {
    print("deleting video ${_videos[index].videoId}");
    final videoInfo = VideoInfo(videoId: _videos[index].videoId);
    await UserVideoStore.deleteUploadedVideo(videoInfo);
  }

  void _deleteButton(int index) async {
    await showMenu(
        context: context,
        color: Colors.yellow[100],
        position: RelativeRect.fromLTRB(125, 530, 125, 0),
        items: [
          PopupMenuItem(
            child: InkWell(
              onTap: () async {
                await removeVideoFromUserAccount(index);
                Navigator.pop(context);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Video Deleted Successfully'),
                ));
                UserDataModel userData = await UserInfoStore()
                    .getUserInformation(uid: _userAuth.user.uid);
                Provider.of<CurrentUser>(context, listen: false)
                    .updateCurrentUser(userData);
                setup();
                setState(() {});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delete",
                    style: TextStyle(color: AppTheme.backColor),
                  ),
                  Icon(Icons.delete_rounded,
                      size: 20, color: AppTheme.backColor),
                ],
              ),
            ),
          )
        ]);
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
              return GestureDetector(
                onLongPress: () {
                  if (widget.uid == _userAuth.user.uid) {
                    _deleteButton(index);
                  }
                },
                onTap: () async {
                  bool isWatched = await UserVideoStore()
                      .checkWatched(videoID: _videos[index].videoId);
                  print(" isWatched: $isWatched");
                  if (!isWatched) {
                    bool result = await UserVideoStore()
                        .increaseVideoCount(videoID: _videos[index].videoId);
                    print(result);
                  }
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        return Player(
                          videos: _videos,
                          index: index,
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
                        image: NetworkImage(_videos[index].thumbUrl),
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

  buildPostStat() {
    return Column(
      children: [
        Text(
          totalPost.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.pureBlackColor,
          ),
        ),
        Text(
          "Posts",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.pureBlackColor,
          ),
        ),
      ],
    );
  }

  getFollowers() {
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
            totalFollowers.toString(),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.pureBlackColor),
          ),
          Text(
            'Followers',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.pureBlackColor),
          ),
        ],
      ),
    );
  }

  getFollowings() {
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
            totalFollowings.toString(),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.pureBlackColor),
          ),
          Text(
            'Following',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.pureBlackColor),
          ),
        ],
      ),
    );
  }
}
