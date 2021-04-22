import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:Chalchitra/imports.dart';

//TODO Change loading card in refresh screen

class HomePageWrapper extends StatefulWidget {
  int currentIndex;
  Function indexController;
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  int currentIndex = 0;
  int currentVideo = 0;
  PageController _controller = PageController();

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

  List<DocumentSnapshot> followingFuture = [];
  List<VideoInfo> videoList = [];
  List<VideoInfo> _videosTrending = [];
  List userInfo = [];
  List trendingUser = [];

  setup() async {
    try {
      bool result;
      await _userInfoStore
          .getFollowingFuture(uid: _userAuth.user.uid)
          .then((value) {
        value.docs.forEach((e) {
          followingFuture.add(e);
        });
      });
      UserVideoStore.listenTopVideos((newVideos) {
        if (this.mounted) {
          setState(() {
            _videosTrending = newVideos;
          });
        }
      });
      if (followingFuture.length != 0) {
        print("fetching following's post");
        await UserVideoStore()
            .getFollowingVideos(followings: followingFuture)
            .then((value)async {
          value.docs.forEach((e) async {
            VideoInfo vid = VideoInfo.fromDocument(e);
            videoList.add(vid);
          });
          result = await fetchUserList();
        });
      }
      result = await fetchTrendingUserList();
      print('result: $result');
      if(result){
        setState(() {
          loading = false;
        });
      }
      print('result: $result');
      return true;
    } on Exception catch (e) {
      print('exception: ${e.toString()}');
    }
  }

  Future fetchUserList() async {
    try {
      await Future.forEach(videoList, (element) async {
        await _userInfoStore.getUserInfo(uid: element.uploaderUid).then((val) {
          userInfo.add(UserDataModel.fromDocument(val));
        });
      });
      return true;
    } catch (e) {}
  }

  Future fetchTrendingUserList() async {
    try {
      await Future.forEach(_videosTrending, (element) async {
        await _userInfoStore.getUserInfo(uid: element.uploaderUid).then((val) {
          trendingUser.add(UserDataModel.fromDocument(val));
        });
      });
      return true;
    } catch (e) {}
  }

  bool loading = true;
  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Column(
          children: [
            Container(
              color: AppTheme.primaryColor,
              child: TabBar(
                indicatorColor: AppTheme.secondaryColor,
                labelColor: AppTheme.secondaryColor,
                unselectedLabelColor: AppTheme.grey,
                tabs: [
                  Tab(
                    child: Text(
                      "Following",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Tab(
                    child: Text("Explore", style: TextStyle(fontSize: 20)),
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  !loading
                      ? TabBarView(
                    children: [
                      videoScrollHome(videos: videoList),
                      videoScrollHome(videos: _videosTrending)
                    ],
                  )
                      : DummyPostCard(),
                  Row(


                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  videoScrollHome({videos}) {
    return //TODO add a zeroFollower Screen
        followingFuture.length == 0
            ? Container(
                child: Center(
                  child: Text(
                    "Explore more talent",
                    style: TextStyle(color: AppTheme.secondaryColor),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    loading = true;
                    followingFuture = [];
                    videos = [];
                    userInfo = [];
                    trendingUser = [];
                  });
                  await setup().then((v) {
                    if (v) {
                      fetchTrendingUserList().then((res) {
                        if (res) {
                          setState(() {
                            loading = false;
                          });
                        }
                      });
                      fetchUserList().then((res) {
                        if (res) {
                          setState(() {
                            loading = false;
                          });
                        }
                      });
                    }
                  });
                },
                child: videos.length == 0
                    ? Container(
                        color: AppTheme.primaryColor,
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
                    : PageView.builder(
                        controller: PageController(keepPage: true),
                        scrollDirection: Axis.vertical,
                        onPageChanged: (val) {
                          setState(() {
                            currentVideo = val;
                          });
                        },
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          return VideoCard(
                            video: videos[index],
                            navigate: () {
                              print("onGoing");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Player(
                                      videos: videos,
                                      index: index,
                                    );
                                  },
                                ),
                              );
                            },
                            playVideo: currentVideo == index,
                            uploader: videos == _videosTrending
                                ? trendingUser[index].username
                                : userInfo[index].username,
                            profileImg: videos == _videosTrending
                                ? trendingUser[index].photoUrl == null
                                    ? "https://via.placeholder.com/150"
                                    : trendingUser[index].photoUrl
                                : userInfo[index].photoUrl == null
                                    ? "https://via.placeholder.com/150"
                                    : userInfo[index].photoUrl,
                          );
                        },
                      ),
              );
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

//Remove this from here
