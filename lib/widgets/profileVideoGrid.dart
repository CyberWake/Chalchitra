import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
import 'package:wowtalent/widgets/videoCardPlaceHolder.dart';

class ProfileVideoGrid extends StatefulWidget {
  final String uid;
  final List<VideoInfo> videos;
  final Function function;
  ProfileVideoGrid({this.uid, this.videos, this.function});
  @override
  _ProfileVideoGridState createState() => _ProfileVideoGridState();
}

class _ProfileVideoGridState extends State<ProfileVideoGrid> {
  UserAuth _userAuth = UserAuth();

  updateVideoWatchCount(int index) async {
    bool isWatched = await UserVideoStore()
        .checkWatched(videoID: widget.videos[index].videoId);
    print(" isWatched: $isWatched");
    if (!isWatched) {
      bool result = await UserVideoStore()
          .increaseVideoCount(videoID: widget.videos[index].videoId);
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 1,
            runSpacing: 1,
            children: List.generate(widget.videos.length, (index) {
              return GestureDetector(
                onLongPress: () {
                  if (widget.uid == _userAuth.user.uid) {
                    widget.function(index);
                  }
                },
                child: FittedBox(
                  child: OpenContainer(
                    closedColor: AppTheme.backgroundColor,
                    closedElevation: 0.0,
                    transitionDuration: Duration(milliseconds: 500),
                    openBuilder: (BuildContext context,
                        void Function({Object returnValue}) action) {
                      updateVideoWatchCount(index);
                      return Player(
                        videos: widget.videos,
                        index: index,
                      );
                    },
                    closedBuilder:
                        (BuildContext context, void Function() action) {
                      return CachedNetworkImage(
                        imageUrl: widget.videos[index].thumbUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          width: size.width * 0.24,
                          height: size.height * 0.24,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.5),
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
                          width: size.width * 0.24,
                          height: size.height * 0.24,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
