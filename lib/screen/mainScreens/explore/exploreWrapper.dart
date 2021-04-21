import 'dart:io';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
// import 'package:wowtalent/model/metaInfo.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/explore/categories.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/search/searchScreenWrapper.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
import 'package:wowtalent/widgets/categoryWidget.dart';
import 'package:wowtalent/widgets/videoCardPlaceHolder.dart';

class ExploreWrapperr extends StatefulWidget {
  @override
  _ExploreWrapperrState createState() => _ExploreWrapperrState();
}

class _ExploreWrapperrState extends State<ExploreWrapperr> {
  final thumbWidth = 100;
  final thumbHeight = 150;
  double staggeredHeight = 200.0;
  double heightIndex1;
  double heightIndex2;
  double heightIndex3;
  Size _size;
  UserAuth _userAuth = UserAuth();
  UserDataModel _user = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  String username = '';
  String url = '';
  double h = 40;

  ScrollController _scroll =
      ScrollController(initialScrollOffset: 14, keepScrollOffset: true);

  List<VideoInfo> _allVideos = <VideoInfo>[];
  List<VideoInfo> _videosTrending = <VideoInfo>[];
  List<UserDataModel> _userInfo = <UserDataModel>[];
  // List<MetaInfo> _allVideosUser = <MetaInfo>[];
  // MetaInfo _info;
  List searchCategories = [
    "Vocals",
    "Dance",
    "Instrumental",
    "Stand-up Comedy",
    "DJing",
    "Acting",
  ];
  List<IconData> searchIcons = [
    Icons.mic,
    Icons.directions_run,
    Icons.music_note,
    Icons.sentiment_very_satisfied,
    Icons.headset,
    Icons.face,
  ];

  getUserInfo(VideoInfo video) async {
    // DocumentSnapshot user =
    //     await _userInfoStore.getUserInfo(uid: video.uploaderUid);
    // _user = UserDataModel.fromDocument(user);
    // setState(() {
    //   _info = MetaInfo(_user.username, _user.photoUrl);
    // });
    // print('ABC ${_info.username}');
  }

  setup() {
    UserVideoStore.listenToAllVideos((newVideos) {
      if (this.mounted) {
        setState(() {
          _allVideos = newVideos;
        });
      }
    });

    UserVideoStore.listenTopVideos((newVideos) {
      if (this.mounted) {
        setState(() {
          _videosTrending = newVideos;
        });
      }
    });

    // getUserInfo(_videosTrending);
  }

  increaseTrendingWatchCount(int index) async {
    bool isWatched = await UserVideoStore()
        .checkWatched(videoID: _videosTrending[index].videoId);
    if (!isWatched) {
      await UserVideoStore()
          .increaseVideoCount(videoID: _videosTrending[index].videoId);
    }
  }

  increaseAllVideoWatchCount(int index) async {
    bool isWatched =
        await UserVideoStore().checkWatched(videoID: _allVideos[index].videoId);
    if (!isWatched) {
      await UserVideoStore()
          .increaseVideoCount(videoID: _allVideos[index].videoId);
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
    // getUserInfo(_allVideos);
  }

  @override
  Widget build(BuildContext context) {
    print('widget called');
    _size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 0,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchScreenWrapper()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 45,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: AppTheme.pureWhiteColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_outlined),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Search for creator or hashtag',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   color: AppTheme.secondaryColor,
          //   width: _size.width,
          //   height: _size.height * 0.07,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: <Widget>[
          //       Padding(
          //         padding: const EdgeInsets.only(left: 15),
          //         child: Row(
          //           children: List.generate(searchCategories.length, (index) {
          //             return GestureDetector(
          //               onTap: () {
          //                 _controller.jumpToPage(index);
          //               },
          //               child: CategoryStoryItem(
          //                 name: searchCategories[index],
          //                 selected: index == currentIndex,
          //               ),
          //             );
          //           }),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  // Center(
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(context,
                  //           MaterialPageRoute(builder: (context) => SearchUser()));
                  //     },
                  //     child: Container(
                  //       width: MediaQuery.of(context).size.width - 40,
                  //       height: 45,
                  //       margin: EdgeInsets.symmetric(vertical: 20),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(10.0),
                  //         color: AppTheme.pureWhiteColor,
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(Icons.search_outlined),
                  //           SizedBox(
                  //             width: 10.0,
                  //           ),
                  //           Text(
                  //             'Search for creator or hashtag',
                  //             style: TextStyle(
                  //               fontSize: 17.0,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // SizedBox(height: 7),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "#TrendingNow",
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.0,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  _trendingVideos(),
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 400,
                  //   color: Colors.white
                  // ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "#JudgePicks",
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.0,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  _staffPicks(),
                  //  Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 400,
                  //   color: Colors.white
                  // ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "#TalentOnFire",
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.normal,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  _latestVideos(),
                  // Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     height: 40,
                  //     color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _averageRating(VideoInfo video) {
    return Positioned(
      right: 30,
      top: 30,
      child: Container(
        padding: EdgeInsets.all(5.0),
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white70,
          border: Border.all(
            color: Colors.white70,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                video.average == null ? '0' : video.average.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.star,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaInfo(VideoInfo video) {
    String url = video.uploaderPic ?? "https://via.placeholder.com/150";
    String name = video.uploaderName ?? 'wowtalents';
    String views = video.views == 0 ? '0' : video.views.toString();
    if (views == null) views = '0';
    print('Video Views : ${video.views}');
    return Positioned(
      bottom: 32,
      left: 20,
      child: Row(
        children: [
          Container(
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              border: new Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(url),
              radius: 30,
            ),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '$views views',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trendingVideos() {
    return Container(
      width: _size.width,
      height: _size.height * 0.4,
      margin: EdgeInsets.all(5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: List.generate(_videosTrending.length, (index) {
          final video = _videosTrending[index];
          // getUserInfo(_videosTrending[index]);
          // final pic = url;
          // final name = username;
          return FittedBox(
            fit: BoxFit.fill,
            child: OpenContainer(
              closedElevation: 0.0,
              closedColor: Colors.transparent,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              transitionDuration: Duration(milliseconds: 200),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (BuildContext context,
                  void Function({Object returnValue}) action) {
                increaseTrendingWatchCount(index);
                return Player(
                  videos: _videosTrending,
                  index: index,
                );
              },
              closedBuilder: (BuildContext context, void Function() action) {
                return Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbUrl ??
                          'https://people.sc.fsu.edu/~jburkardt/data/png/bmp_08.png',
                      // imageBuilder: (context, imageProvider) => DummyVideoCard(
                      //   width: _size.width * 0.8,
                      //   height: _size.height * 0.7,
                      // ),
                      imageBuilder: (context, imageProvider) => Stack(
                        children: [
                          Container(
                            width: _size.width * 0.8,
                            height: _size.height * 0.7,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.grey,
                                width: 0.8,
                              ),
                              color: AppTheme.pureBlackColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  offset: Offset(0.0, 10.0), //(x,y)
                                  blurRadius: 10.0,
                                ),
                              ],
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.fitWidth),
                            ),
                          ),
                          _metaInfo(video),
                          _averageRating(video),
                        ],
                      ),
                      placeholder: (context, url) => DummyVideoCard(
                        width: _size.width * 0.8,
                        height: _size.height * 0.7,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    // Positioned(
                    //   child: _metaInfo(video),
                    //   bottom: 32,
                    //   left: 20,
                    // ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _staffPicks() {
    // print('All videos info $_allVideosUser');
    print('Staff picked called');
    return Container(
      width: _size.width,
      height: _size.height * 0.4,
      margin: EdgeInsets.all(7),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: List.generate(_allVideos.length, (index) {
          final video = _allVideos[index];
          return FittedBox(
            child: OpenContainer(
              closedElevation: 0.0,
              closedColor: Colors.transparent,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              transitionDuration: Duration(milliseconds: 200),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (BuildContext context,
                  void Function({Object returnValue}) action) {
                increaseAllVideoWatchCount(index);
                return Player(
                  videos: _allVideos,
                  index: index,
                );
              },
              closedBuilder: (BuildContext context, void Function() action) {
                return Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbUrl,
                      fit: BoxFit.scaleDown,
                      imageBuilder: (context, imageProvider) => Container(
                        width: _size.width * 0.8,
                        height: _size.height * 0.7,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(10.5),
                          border: Border.all(
                            color: AppTheme.grey,
                          ),
                          color: AppTheme.pureBlackColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              offset: Offset(0.0, 10.0), //(x,y)
                              blurRadius: 10.0,
                            ),
                          ],
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.fitWidth),
                        ),
                      ),
                      placeholder: (context, url) => DummyVideoCard(
                        width: _size.width * 0.8,
                        height: _size.height * 0.7,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    _metaInfo(video),
                    _averageRating(video),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _latestVideos() {
    return Container(
      width: _size.width,
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        itemCount: _allVideos.length,
        itemBuilder: (BuildContext context, int index) {
          dynamic video = _allVideos[index];
          return GestureDetector(
            onTap: () async {
              increaseAllVideoWatchCount(index);
              Navigator.push(
                context,
                Platform.isIOS
                    ? CupertinoPageRoute(builder: (context) {
                        return Player(
                          videos: _allVideos,
                          index: index,
                        );
                      })
                    : MaterialPageRoute(
                        builder: (context) {
                          return Player(
                            videos: _allVideos,
                            index: index,
                          );
                        },
                      ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: video.thumbUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Shimmer.fromColors(
                highlightColor: AppTheme.pureWhiteColor,
                baseColor: AppTheme.grey,
                child: Container(
                  margin: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(1, 1 / _allVideos[index].aspectRatio);
        },
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
      ),
    );
  }
}
