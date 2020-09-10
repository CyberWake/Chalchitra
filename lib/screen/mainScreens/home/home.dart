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
        itemCount: _videos.length,
        itemBuilder: (context, index){
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _widthOne * 50,
              vertical: _heightOne * 20
            ),
            child: PostCard(
              thumbnail: _videos[index].thumbUrl,
              profileImg: posts[0]['profileImg'],
              title: _videos[index].videoName,
              uploader: posts[0]['name'],
              isLiked: posts[0]['isLoved'],
              likeCount: _videos[index].likes,
              commentCount: _videos[index].comments,
              uploadTime: formatDateTime(_videos[index].uploadedAt),
              viewCount: index * Random().nextInt((index + 1) * 100) + 1,
            ),
          );
        },
      )
    );
  }

  String formatDateTime(int millisecondsSinceEpoch){
    DateTime uploadTimeStamp =
    DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String sentAt = uploadTimeStamp.toString();
    Duration difference = DateTime.now().difference(DateTime.parse(sentAt));

    if(difference.inDays > 0){
      if(difference.inDays > 365){
        sentAt = (difference.inDays / 365).floor().toString() + ' years ago';
      }
      if(difference.inDays > 30 && difference.inDays < 365){
        sentAt = (difference.inDays / 30).floor().toString() + ' months ago';
      }
      if(difference.inDays >=1 && difference.inDays < 305){
        sentAt = difference.inDays.floor().toString() + ' days ago';
      }
    }
    else if(difference.inHours > 0){
      sentAt = difference.inHours.toString() + ' hours ago';
    }
    else if(difference.inMinutes > 0){
      sentAt = difference.inMinutes.toString() + ' mins ago';
    }
    else{
      sentAt = difference.inSeconds.toString() + ' secs';
    }

    return sentAt;
  }
}
