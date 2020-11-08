import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/notificationInfo.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

class NotificationCard extends StatefulWidget {
  final String type;
  final String from;
  final String videoId;
  NotificationCard({this.type, this.from, this.videoId});
  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  UserInfoStore _userInfo = UserInfoStore();
  UserVideoStore _userVideoStore = UserVideoStore();
  List<VideoInfo> videos = [];
  VideoInfo video = VideoInfo();
  String nullImageUrl =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  getLikedVideo() async {
    VideoInfo video =
        await _userVideoStore.getLikedVideo(videoId: widget.videoId);
    videos.add(video);
    await Future.delayed(Duration(seconds: 2), () {
      if (videos.isNotEmpty) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => Player(
                      videos: videos,
                      index: 0,
                    )));
      }
    });
    setState(() {});
  }

  Future<NotifInfo> assignNotif(uid, videoID) async {
    NotifInfo _notifInfo = NotifInfo();
    UserDataModel user;
    user = await _userInfo.getUserInformation(uid: uid);
    _notifInfo.userInfo = user;
    VideoInfo videoInfo;
    videoInfo = await _userVideoStore.getVideoInfo(videoid: videoID);
    _notifInfo.vidInfo = videoInfo;
    return _notifInfo;
  }

  Future notifFuture;
  String notifType;
  String notifTitle;
  @override
  void initState() {
    notifFuture = assignNotif(widget.from, widget.videoId);
    switch (widget.type) {
      case "like":
        setState(() {
          notifTitle = "New Like";
          notifType = "liked your video";
        });
        break;
      case "comment":
        setState(() {
          notifTitle = "New Comment";
          notifType = "commented on your video";
        });
        break;
      case "follow":
        setState(() {
          notifTitle = "New Follower";
          notifType = "started following you";
        });
        break;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: FutureBuilder(
            future: notifFuture,
            builder: (context, snap) {
              if (!snap.hasData) {
                return Shimmer.fromColors(
                  highlightColor: AppTheme.pureWhiteColor,
                  baseColor: AppTheme.grey,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.backgroundColor,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  onTap: () {
                    switch (widget.type) {
                      case "like":
                        getLikedVideo();
                        break;
                      case "comment":
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => CommentsScreen(
                                      videoId: widget.videoId,
                                    )));
                        break;
                      case "follow":
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => SearchProfile(
                                      uid: widget.from,
                                    )));
                        break;
                    }
                  },
                  leading: widget.type == "follow"
                      ? Icon(
                          Icons.supervised_user_circle,
                          size: 50,
                        )
                      : CachedNetworkImage(
                          width: 50,
                          height: 50,
                          imageUrl: snap.data.userInfo.photoUrl == null
                              ? nullImageUrl
                              : snap.data.userInfo.photoUrl,
                          imageBuilder: (context, imgProvider) => CircleAvatar(
                            backgroundColor: AppTheme.backgroundColor,
                            backgroundImage: imgProvider,
                          ),
                        ),
                  trailing: Container(
                    width: 70,
                    height: 70,
                    decoration: widget.type == "follow"
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                              snap.data.userInfo.photoUrl == null
                                  ? nullImageUrl
                                  : snap.data.userInfo.photoUrl,
                            )))
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    snap.data.vidInfo.thumbUrl))),
                  ),
                  subtitle: Text(
                    "${snap.data.userInfo.username} ${notifType}",
                    style: TextStyle(color: Colors.black),
                  ),
                  title: Text(notifTitle),
                ),
              );
            },
          )),
    );
  }
}
