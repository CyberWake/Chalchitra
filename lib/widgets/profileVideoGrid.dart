import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Chalchitra/imports.dart';

class ProfileVideoGrid extends StatefulWidget {
  final String uid;
  final String name;
  final List<VideoInfo> videos;
  final Function function;
  ProfileVideoGrid({this.name, this.uid, this.videos, this.function});
  @override
  _ProfileVideoGridState createState() => _ProfileVideoGridState();
}

class _ProfileVideoGridState extends State<ProfileVideoGrid> {
  UserAuth _userAuth = UserAuth();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isCurrentUser = false;

  getCurrentUser() {
    final User user = _auth.currentUser;
    final userid = user.uid;
    if (userid == widget.uid) {
      setState(() {
        isCurrentUser = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

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

  Widget build(context) {
    Size _size = MediaQuery.of(context).size;
    return widget.videos.length == 0
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    isCurrentUser
                        ? "You dont have any posts here yet!"
                        : "@${widget.name} does not have any post yet \nask them to show their talent",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                InkWell(
                  child: Text(isCurrentUser ? "Create Post" : "",
                      style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  onTap: () {},
                )
              ],
            ),
          )
        : StaggeredGridView.countBuilder(
            // staggeredTileBuilder: (index) => StaggeredTile.count(1, 1),
            staggeredTileBuilder: (int
                    index) => // staggeredTileBuilder: (int index) =>
                StaggeredTile.count(1, 1 / widget.videos[index].aspectRatio),
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            itemCount: widget.videos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  if (widget.uid == _userAuth.user.uid) {
                    widget.function(index, widget.name);
                  }
                },
                child: FittedBox(
                  child: OpenContainer(
                    closedColor: Colors.transparent,
                    closedElevation: 0.0,
                    closedShape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    transitionDuration: Duration(milliseconds: 200),
                    openBuilder: widget.name == "drafts"
                        ? (context, action) {
                            return VideoUploadForm(
                              isFromDraft: true,
                              mediaInfoPath: widget.videos[index].videoUrl,
                              thumbnailPath: widget.videos[index].thumbUrl,
                              aspectRatio: widget.videos[index].aspectRatio,
                            );
                          }
                        : (context, action) {
                            updateVideoWatchCount(index);
                            return Player(
                              videos: widget.videos,
                              index: index,
                              user: UserAuth.currentUserModel,
                            );
                          },
                    closedBuilder: (context, action) {
                      return CachedNetworkImage(
                        placeholder: (context, url) {
                          return DummyVideoCard(
                            width: _size.width * 0.24,
                            height: _size.height * 0.24,
                          );
                        },
                        errorWidget: (context, url, error) {
                          Icon(Icons.error);
                        },
                        imageUrl: widget.videos[index].thumbUrl,
                        imageBuilder: (context, imageProvider) {
                          return ClipRRect(
                            child: Image(
                              fit: BoxFit.cover,
                              image: imageProvider,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
  }

  // @override
  // Widget build(BuildContext context) {
  //   var size = MediaQuery.of(context).size;
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Wrap(
  //           spacing: 1,
  //           runSpacing: 1,
  //           children: List.generate(widget.videos.length, (index) {
  //             return GestureDetector(
  //               onLongPress: () {
  //                 if (widget.uid == _userAuth.user.uid) {
  //                   widget.function(index);
  //                 }
  //               },
  //               child: FittedBox(
  //                 child: OpenContainer(
  //                   closedColor: Colors.transparent,
  //                   closedElevation: 0.0,
  //                   closedShape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.zero,
  //                   ),
  //                   transitionDuration: Duration(milliseconds: 200),
  //                   transitionType: ContainerTransitionType.fadeThrough,
  //                   openBuilder: (BuildContext context,
  //                       void Function({Object returnValue}) action) {
  //                     updateVideoWatchCount(index);
  //                     return Player(
  //                       videos: widget.videos,
  //                       index: index,
  //                     );
  //                   },
  //                   closedBuilder:
  //                       (BuildContext context, void Function() action) {
  //                     return CachedNetworkImage(
  //                       imageUrl: widget.videos[index].thumbUrl,
  //                       imageBuilder: (context, imageProvider) => Container(
  //                         width: size.width * 0.24,
  //                         height: size.height * 0.24,
  //                         margin: EdgeInsets.all(5),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(10.5),
  //                           color: AppTheme.pureBlackColor,
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: AppTheme.primaryColor.withOpacity(0.2),
  //                               offset: Offset(0.0, 10.0), //(x,y)
  //                               blurRadius: 10.0,
  //                             ),
  //                           ],
  //                           image: DecorationImage(
  //                               image: imageProvider, fit: BoxFit.fitWidth),
  //                         ),
  //                       ),
  //                       placeholder: (context, url) => DummyVideoCard(
  //                         width: size.width * 0.24,
  //                         height: size.height * 0.24,
  //                       ),
  //                       errorWidget: (context, url, error) => Icon(Icons.error),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             );
  //           }),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
