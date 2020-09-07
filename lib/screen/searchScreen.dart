import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wowtalent/data/search_json.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/widgets/search_category_widget.dart';
import './userSearchScreen.dart';
import '../model/video_info.dart';
import '../video_uploader_widget/player.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = new TextEditingController();
  final thumbWidth = 100;
  final thumbHeight = 150;

  List<VideoInfo> _videos = <VideoInfo>[];

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
    return getBody();
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        SafeArea(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 15,
                height: 30,
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SearchUser())),
                child: Container(
                    margin: const EdgeInsets.only(top: 15),
                    width: size.width - 30,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Hexcolor('#F23041'),
                        size: 35,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Search...',
                        style: TextStyle(fontSize: 22),
                      )
                    ])),
              ),
              SizedBox(
                width: 15,
              )
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
                children: List.generate(searchCategories.length, (index) {
              return CategoryStoryItem(
                name: searchCategories[index],
              );
            })),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Wrap(
          spacing: 1,
          runSpacing: 1,
          children: List.generate(_videos.length, (index) {
            print(_videos.length);
            final video = _videos[index];
            print(video);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Player(
                        video: video,
                      );
                    },
                  ),
                );
              },
              child: Container(
                width: (size.width - 3) / 3,
                height: (size.width - 3) / 3,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(video.thumbUrl),
                        fit: BoxFit.cover)),
              ),
            );
          }),
        )
      ],
    ));
  }
}
