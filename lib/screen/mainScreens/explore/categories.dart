import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';
import 'dart:io';

class Category extends StatefulWidget {
  final String categoryName;
  Category({this.categoryName});
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  double _iconOne;
  Size _size;
  double _widthOne;
  List<VideoInfo> _videos = <VideoInfo>[];

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

  @override
  void initState() {
    super.initState();
    UserVideoStore.listenToCategoryVideos((newVideos) {
      if (this.mounted) {
        setState(() {
          _videos = newVideos;
        });
      }
    }, widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _iconOne = (_size.height * 0.066) / 50;
    return Platform.isIOS
        ? CategoryIOS(
            categoryBody: categoryBody(),
            categoryName: widget.categoryName,
          )
        : Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: categoryBody(),
          );
  }

  Widget categoryBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _videos.length == 0
          ? Center(
              child: Text(
              "No videos found",
              style: TextStyle(color: AppTheme.pureWhiteColor),
            ))
          : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                child: Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _videos.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic video = _videos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
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
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryLoading,
                            image: DecorationImage(
                              image: NetworkImage(video.thumbUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    // staggeredTileBuilder: (int index) =>
                    //     StaggeredTile.count(1, 1 / _videos[index].aspectRatio),
                    // mainAxisSpacing: 5.0,
                    // crossAxisSpacing: 5.0,
                  ),
                ),
              ),
            ]),
    );
  }
}
