import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
import 'package:wowtalent/widgets/categoryWidget.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final thumbWidth = 100;
  final thumbHeight = 150;
  double staggeredHeight = 200.0;
  double heightIndex1;
  double heightIndex2;
  double heightIndex3;
  Size _size;
  UserAuth _userAuth = UserAuth();

  List<VideoInfo> _allVideos = <VideoInfo>[];
  List<VideoInfo> _videosTrending = <VideoInfo>[];
  List searchCategories = [
    "Vocals",
    "Dance",
    "Instrumental",
    "Stand up Comedy",
    "DJing",
    "Acting",
  ];

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _categories(),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "#Trending",
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            _trendingVideos(),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "#StaffPicks",
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            _staffPicks(),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "#LatestVideos",
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            _latestVideos(),
          ],
        ),
      ),
    );
  }

  Widget _categories() {
    return Container(
      width: _size.width,
      height: _size.height * 0.07,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: List.generate(searchCategories.length, (index) {
                return CategoryStoryItem(
                  name: searchCategories[index],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendingVideos() {
    return Container(
      width: _size.width,
      height: _size.height * 0.25,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: List.generate(_videosTrending.length, (index) {
          final video = _videosTrending[index];
          return GestureDetector(
            onTap: () async {
              bool isWatched = await UserVideoStore()
                  .checkWatched(videoID: _videosTrending[index].videoId);
              if (!isWatched) {
                await UserVideoStore().increaseVideoCount(
                    videoID: _videosTrending[index].videoId);
              }
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) {
                    return Player(
                      video: video,
                    );
                  },
                ),
              );
            },
            child: Container(
              width: _size.width * 0.25,
              height: _size.height * 0.25,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: NetworkImage(video.thumbUrl), fit: BoxFit.fitWidth),
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
    );
  }

  Widget _staffPicks() {
    return Container(
      width: _size.width,
      height: _size.height * 0.25,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: List.generate(_allVideos.length, (index) {
          final video = _allVideos[index];
          return GestureDetector(
            onTap: () async {
              bool isWatched = await UserVideoStore()
                  .checkWatched(videoID: _allVideos[index].videoId);
              if (!isWatched) {
                await UserVideoStore()
                    .increaseVideoCount(videoID: _allVideos[index].videoId);
              }
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) {
                    return Player(
                      video: video,
                    );
                  },
                ),
              );
            },
            child: Container(
              width: _size.width * 0.25,
              height: _size.height * 0.25,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: NetworkImage(video.thumbUrl), fit: BoxFit.fitWidth),
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
              bool isWatched = await UserVideoStore()
                  .checkWatched(videoID: _allVideos[index].videoId);
              if (!isWatched) {
                await UserVideoStore()
                    .increaseVideoCount(videoID: _allVideos[index].videoId);
              }
              Navigator.push(
                context,
                Platform.isIOS
                    ? CupertinoPageRoute(builder: (context) {
                        return Player(
                          video: video,
                        );
                      })
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
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  image: DecorationImage(
                      image: NetworkImage(video.thumbUrl), fit: BoxFit.cover)),
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
