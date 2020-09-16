import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_uploader_widget/player.dart';
import 'package:wowtalent/widgets/search_category_widget.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  final thumbWidth = 100;
  final thumbHeight = 150;

  List<VideoInfo> _videos = <VideoInfo>[];
  List searchCategories = [
    "Vocals",
    "Precussions",
    "Performing Arts",
    "Instrumental",
    "Videography",
    "Stand up Comedy",
    "DIY",
  ];

  @override
  void initState() {
    super.initState();
    UserVideoStore.listenToAllVideos((newVideos) {
      if(this.mounted){
        setState(() {
          _videos = newVideos;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        height: size.height * 1.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "TRENDING",
                style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_videos.length, (index) {
                  final video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                     Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Player(
                            video: video,
                          );
                        },
                      ),);
                    },
                    child: Container(
                      width: size.width * 0.2,
                      height: size.height * 0.2,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                            image: NetworkImage(video.thumbUrl),
                            fit: BoxFit.fitWidth
                        ),
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
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "STAFF PICKS",
                style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(_videos.length, (index) {
                  final video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                     Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Player(
                            video: video,
                          );
                        },
                      ),);
                    },
                    child: Container(
                      width: size.width * 0.2,
                      height: size.height * 0.2,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                            image: NetworkImage(video.thumbUrl),
                            fit: BoxFit.fitWidth
                        ),
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
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "LATEST VIDEOS",
                style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Expanded(
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 3,
                itemCount: _videos.length,
                itemBuilder: (BuildContext context, int index){
                  dynamic video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Player(
                            video: video,
                          );
                        },
                      ),);
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
                    StaggeredTile.count(1, 1/_videos[index].aspectRatio),
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
