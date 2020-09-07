import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wowtalent/data/post_json.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/screen/mainScreens/home/postCard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<VideoInfo> _videos = <VideoInfo>[];
  double _widthOne;
  double _heightOne;

  @override
  void initState() {
    super.initState();
    UserVideoStore.listenToAllVideos((newVideos) {
      setState(() {
        _videos = newVideos;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _widthOne = size.width * 0.0008;
    _heightOne = (size.height * 0.007) / 5;
    return Center(
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index){
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _widthOne * 50,
              vertical: _heightOne * 20
            ),
            child: PostCard(
              thumbnail: posts[index]['postImg'],
              profileImg: posts[index]['profileImg'],
              title: posts[index]['caption'],
              uploader: posts[index]['name'],
              isLiked: posts[index]['isLoved'],
              likeCount: int.parse(posts[index]['commentCount']) * 10,
              commentCount: int.parse(posts[index]['commentCount']),
              uploadTime: posts[index]['timeAgo'],
              viewCount: index * Random().nextInt((index + 1) * 100) + 1,
            ),
          );
        },
      )
    );
  }
}
