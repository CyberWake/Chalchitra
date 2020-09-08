import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wowtalent/data/search_json.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/video_uploader_widget/player.dart';
import 'package:wowtalent/widgets/search_category_widget.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
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
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
                children: List.generate(searchCategories.length, (index) {
                  return CategoryStoryItem(
                    name: searchCategories[index],
                  );
                }),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            itemCount: _videos.length,
            itemBuilder: (BuildContext context, int index){
              dynamic video = _videos[index];
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
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(video.thumbUrl),
                          fit: BoxFit.cover
                      )
                  ),
                ),
              );
            },
            staggeredTileBuilder: (int index) =>
                StaggeredTile.count(1, _videos[index].aspectRatio),
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
          ),
        )
      ],
    );
  }
}
