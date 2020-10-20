import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

class Category extends StatefulWidget {
  String categoryName;
  Category({this.categoryName});
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  double _iconOne;
  Size _size;
  double _widthOne;
  List<VideoInfo> _videos = <VideoInfo>[];

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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppTheme.pureBlackColor,
              size: _iconOne * 30,
            ),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SearchUser()));
            },
          ),
          SizedBox(
            width: _widthOne * 100,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _videos.length == 0
            ? Center(
                child: Text(
                "No videos found",
                style: TextStyle(color: AppTheme.primaryColor),
              ))
            : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
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
                              image: DecorationImage(
                                  image: NetworkImage(video.thumbUrl),
                                  fit: BoxFit.cover)),
                        ),
                      );
                    },
                    staggeredTileBuilder: (int index) =>
                        StaggeredTile.count(1, 1 / _videos[index].aspectRatio),
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                  ),
                ),
              ]),
      ),
    );
  }
}
