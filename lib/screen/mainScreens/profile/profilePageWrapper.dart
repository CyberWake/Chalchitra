import 'dart:io';

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
import 'package:wowtalent/screen/mainScreens/activitySection/messages/chatScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/editProfilePage.dart';
import 'package:wowtalent/screen/mainScreens/profile/editVideoForm.dart';
// import 'package:wowtalent/screen/mainScreens/profile/editProfileScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/followersScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/followingsScreen.dart';
import 'package:wowtalent/screen/mainScreens/settings/settingsScreen.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_upload_screens/videoUploadForm.dart';
import 'package:wowtalent/widgets/bouncingButton.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';
import 'package:wowtalent/widgets/profileMessageGrid.dart';
import 'package:wowtalent/widgets/profileVideoGrid.dart';

class ProfilePageWrapper extends StatefulWidget {
  final bool isFromSearch;
  final String url =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final String uid;
  ProfilePageWrapper({this.isFromSearch, this.uid});
  @override
  _ProfilePageWrapperState createState() => _ProfilePageWrapperState();
}

class _ProfilePageWrapperState extends State<ProfilePageWrapper>
    with TickerProviderStateMixin {
  UserDataModel user;
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _userAuth = UserAuth();

  bool loading = false;
  bool following = false;
  bool isSecure = false;
  bool seeFollowers = false;
  bool seeFollowings = false;
  bool refreshVideos = false;
  bool processing = false;

  String currentUserID;
  String currentUserImgUrl;
  String currentUserDisplayName;
  String currentUserUsername;
  String currentUserBio;
  int totalFollowers = 0;
  int totalFollowings = 0;
  int totalPost = 0;

  List<VideoInfo> _videos = <VideoInfo>[];
  List<VideoInfo> _draftVideo = <VideoInfo>[];

  void setup() async {
    dynamic result = await UserVideoStore().getProfileVideos(uid: widget.uid);
    dynamic draft = await UserVideoStore().getDraftVideos(uid: widget.uid);
    if (result != false) {
      setState(() {
        _videos = result;
        _draftVideo = draft;
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

  List<Widget> profileTop(context) {
    List<Widget> topWidgets = [
      Column(
        children: [
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.isFromSearch
                    ? IconButton(
                        icon: Icon(
                          Icons.message,
                          color: AppTheme.pureWhiteColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => ChatScreen(
                                        targetUID: widget.uid,
                                      )));
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: AppTheme.pureWhiteColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => SettingScreen()));
                        },
                      ),
              ],
            ),
          ),
          CircleAvatar(
            child: CachedNetworkImage(
              imageUrl:
                  currentUserImgUrl != null ? currentUserImgUrl : widget.url,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              currentUserDisplayName == null
                  ? "WowTalent"
                  : currentUserDisplayName,
              style: TextStyle(color: AppTheme.pureWhiteColor, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                currentUserUsername == null ? "WowTalent" : currentUserUsername,
                style: TextStyle(color: AppTheme.pureWhiteColor, fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(currentUserBio == null ? "WowTalent" : currentUserBio,
                style: TextStyle(color: AppTheme.pureWhiteColor, fontSize: 18)),
          ),
          Padding(padding: EdgeInsets.all(8), child: createButton()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [getFollowers(), buildPostStat(), getFollowings()],
            ),
          ),
        ],
      ),
    ];
    return topWidgets;
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
    return Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverList(
                      delegate: SliverChildListDelegate(profileTop(context)))
                ];
              },
              body: Column(
                children: [
                  TabBar(
                    indicatorColor: AppTheme.secondaryColor,
                    labelColor: AppTheme.secondaryColor,
                    unselectedLabelColor: AppTheme.grey,
                    tabs: [
                      Tab(
                        child: Icon(Icons.grid_on),
                      ),
                      Tab(
                        child: Icon(Icons.drafts),
                      )
                    ],
                  ),
                  Expanded(
                      child: TabBarView(
                    children: [
                      ProfileVideoGrid(
                        uid: widget.uid,
                        videos: _videos,
                        function: _deleteButton,
                        name: currentUserUsername,
                      ),
                      ProfileMessageGrid(
                        uid: widget.uid,
                        name: currentUserUsername,
                        videos: _draftVideo,
                        function: _deleteButton,
                      )
                    ],
                  ))
                ],
              ),
            ),
          ),
        ));
  }

  createButton() {
    bool userProfile = currentUserID == widget.uid;
    print("$currentUserID : ${widget.uid}");
    if (userProfile) {
      return BouncingButton(
        buttonText: "Edit Profile",
        width: MediaQuery.of(context).size.width * 0.4,
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

  updateVideoIndex(VideoInfo vid, index) {
    setState(() {
      _videos[index] = vid;
    });
  }

  void editPageRoute(int index) async {
    final vid = await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => EditVideoForm(
                  video: _videos[index],
                )));
    updateVideoIndex(vid, index);
  }

  void _deleteButton(int index, String name) async {
    int result = await showMenu(
        context: context,
        color: AppTheme.secondaryColor,
        position: RelativeRect.fromLTRB(125, 530, 125, 0),
        items: [
          PopupMenuItem(
            value: 1,
            height: 50,
            child: GestureDetector(
              onTap: name == "posts"
                  ? () {
                      editPageRoute(index);
                      setup();
                      setState(() {});
                    }
                  : () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => VideoUploadForm(
                                    isFromDraft: true,
                                    mediaInfoPath: _draftVideo[index].videoUrl,
                                    thumbnailPath: _draftVideo[index].thumbUrl,
                                    aspectRatio: _draftVideo[index].aspectRatio,
                                  )));
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit",
                    style: TextStyle(color: AppTheme.pureBlackColor),
                  ),
                  Icon(Icons.edit, size: 20, color: AppTheme.pureBlackColor),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            value: 0,
            height: 50,
            child: GestureDetector(
              onTap: () async {
                await removeVideoFromUserAccount(index, context);
                Navigator.pop(context);
                Platform.isIOS
                    ? cupertinoSnackbar(context, "Video Deleted Successfully")
                    : Scaffold.of(context).showSnackBar(SnackBar(
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
                    style: TextStyle(color: AppTheme.pureBlackColor),
                  ),
                  Icon(Icons.delete_rounded,
                      size: 20, color: AppTheme.pureBlackColor),
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
    } else if (result == 1) {
      name == "posts"
          ? Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => EditVideoForm(
                        video: _videos[index],
                      )))
          : Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => VideoUploadForm(
                        isFromDraft: true,
                        mediaInfoPath: _draftVideo[index].videoUrl,
                        thumbnailPath: _draftVideo[index].thumbUrl,
                        aspectRatio: _draftVideo[index].aspectRatio,
                      )));
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
            color: AppTheme.pureWhiteColor,
          ),
        ),
        Text(
          "Posts",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.pureWhiteColor,
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
                  color: AppTheme.pureWhiteColor),
            ),
            Text(
              'Followers',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pureWhiteColor),
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
                  color: AppTheme.pureWhiteColor),
            ),
            Text(
              'Following',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pureWhiteColor),
            ),
          ],
        );
      },
    );
  }
}
