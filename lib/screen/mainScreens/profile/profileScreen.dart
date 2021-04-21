import 'package:animations/animations.dart';
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
import 'package:wowtalent/widgets/bouncingButton.dart';
import 'package:wowtalent/widgets/profileVideoGrid.dart';

class ProfilePage extends StatefulWidget {
  final bool isFromSearch;
  final String url =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final String uid;

  ProfilePage({@required this.uid, this.isFromSearch = false});

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
  bool processing = false;

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
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
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
                    height: widget.isFromSearch
                        ? size.height * 0.5324
                        : size.height * 0.4557247,
                    width: size.width,
                    margin: EdgeInsets.only(top: size.height * 0.35),
                    padding: EdgeInsets.only(
                        top: size.height * 0.1,
                        left: size.width * 0.05,
                        right: size.width * 0.05),
                    child: ProfileVideoGrid(
                      uid: widget.uid,
                      videos: _videos,
                      function: _deleteButton,
                    ),
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
                        color: AppTheme.secondaryColor,
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
                                  getFollowers(),
                                  buildPostStat(),
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
        color: AppTheme.primaryColor,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.08,
                ),
                CircleAvatar(
                  child: CachedNetworkImage(
                    imageUrl: currentUserImgUrl != null
                        ? currentUserImgUrl
                        : widget.url,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.08,
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
      return BouncingButton(
        buttonText: "Edit Profile",
        width: MediaQuery.of(context).size.width * 0.6,
        buttonFunction: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => EditProfilePage(
                        uid: currentUserID,
                      )));
          setState(() {});
        },
      );
    } else if (following) {
      return BouncingButton(
        buttonText: "Unfollow",
        width: MediaQuery.of(context).size.width * 0.6,
        buttonFunction: () {
          controlUnFollowUsers();
          setState(() {});
        },
      );
    } else if (!following) {
      return BouncingButton(
        buttonText: "Follow",
        width: MediaQuery.of(context).size.width * 0.6,
        buttonFunction: () {
          controlFollowUsers();
          setState(() {});
        },
      );
    }
  }

  controlUnFollowUsers() async {
    if (!processing) {
      setState(() {
        processing = true;
      });
      bool result = await _userInfoStore.unFollowUser(uid: widget.uid);
      if (!result) {
        user = await _userInfoStore.getUserInformation(uid: _userAuth.user.uid);
        Provider.of<CurrentUser>(context, listen: false)
            .updateCurrentUser(user);
        totalFollowers -= 1;
        setState(() {
          processing = false;
        });
      }
      _videos = [];
      getPrivacy();
      setState(() {
        following = result;
      });
    }
  }

  controlFollowUsers() async {
    if (!processing) {
      setState(() {
        processing = true;
      });
      bool result = await _userInfoStore.followUser(uid: widget.uid);
      if (result) {
        user = await _userInfoStore.getUserInformation(uid: _userAuth.user.uid);
        Provider.of<CurrentUser>(context, listen: false)
            .updateCurrentUser(user);
        totalFollowers += 1;
        setState(() {
          processing = false;
        });
      }
      mySuper();
      setState(() {
        following = result;
      });
    }
  }

  removeVideoFromUserAccount(int index, context) async {
    print("deleting video ${_videos[index].videoId}");
    final videoInfo = VideoInfo(videoId: _videos[index].videoId);
    await UserVideoStore.deleteUploadedVideo(videoInfo, context);
  }

  void _deleteButton(int index) async {
    int result = await showMenu(
        context: context,
        color: Colors.yellow[100],
        position: RelativeRect.fromLTRB(125, 530, 125, 0),
        items: [
          PopupMenuItem(
            value: 0,
            height: 50,
            child: GestureDetector(
              onTap: () async {
                await removeVideoFromUserAccount(index, context);
                Navigator.pop(context);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Video Deleted Successfully'),
                ));
                setup();
                setState(() {});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delete",
                    style: TextStyle(color: AppTheme.primaryColorDark),
                  ),
                  Icon(Icons.delete_rounded,
                      size: 20, color: AppTheme.primaryColorDark),
                ],
              ),
            ),
          )
        ]);
    if (result == 0) {
      await removeVideoFromUserAccount(index, context);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Video Deleted Successfully'),
      ));
      setup();
      setState(() {});
    }
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
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0.0,
      tappable: seeFollowers,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      transitionDuration: Duration(milliseconds: 200),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder:
          (BuildContext context, void Function({Object returnValue}) action) {
        return FollowersPage(uid: widget.uid);
      },
      closedBuilder: (BuildContext context, void Function() action) {
        return Column(
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
        );
      },
    );
  }

  getFollowings() {
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0.0,
      tappable: seeFollowers,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      transitionDuration: Duration(milliseconds: 200),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder:
          (BuildContext context, void Function({Object returnValue}) action) {
        return FollowingsPage(uid: widget.uid);
      },
      closedBuilder: (BuildContext context, void Function() action) {
        print("called");
        return Column(
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
        );
      },
    );
  }
}
