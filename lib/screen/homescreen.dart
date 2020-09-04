import 'package:flutter/material.dart';
import 'package:wowtalent/data/post_json.dart';
import 'package:wowtalent/widgets/post_widget.dart';
import '../database/firebase_provider.dart';
import '../model/video_info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final thumbWidth = 100;
  final thumbHeight = 150;

  List<VideoInfo> _videos = <VideoInfo>[];

  void initState() {
    UserVideoStore.listenToAllVideos((newVideos) {
      setState(() {
        _videos = newVideos;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return getPost();
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Column(
            children: List.generate(posts.length, (index) {
              return PostItem(
                postImg: posts[index]['postImg'],
                profileImg: posts[index]['profileImg'],
                name: posts[index]['name'],
                caption: posts[index]['caption'],
                isLoved: posts[index]['isLoved'],
                viewCount: posts[index]['commentCount'],
                likedBy: posts[index]['likedBy'],
                dayAgo: posts[index]['dayAgo'],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget getPost() {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostItem(
          postImg: posts[index]['postImg'],
          profileImg: posts[index]['profileImg'],
          name: posts[index]['name'],
          caption: posts[index]['caption'],
          isLoved: posts[index]['isLoved'],
          viewCount: posts[index]['commentCount'],
          likedBy: posts[index]['likedBy'],
          dayAgo: posts[index]['dayAgo'],
        );
      },
    );
  }
}
