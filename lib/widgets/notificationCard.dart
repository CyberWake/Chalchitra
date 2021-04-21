import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/notificationInfo.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
import 'package:wowtalent/widgets/loadingTiles.dart';

class NotificationCard extends StatefulWidget {
  final String type;
  final String from;
  final String videoId;
  final bool read;
  Function onTap;
  NotificationCard({this.onTap, this.read, this.type, this.from, this.videoId});
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
                    ))).then((value) => widget.onTap());
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

  Stream<NotifInfo> getNotif() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 1));
      yield await assignNotif(widget.from, widget.videoId);
    }
  }

  Future notifFuture;
  String notifType;
  String notifTitle;
  @override
  void initState() {
    notifFuture = assignNotif(widget.from, widget.videoId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case "like":
        setState(() {
          notifTitle = !widget.read ? "New Like" : "Like";
          notifType = "liked your video";
        });
        break;
      case "comment":
        setState(() {
          notifTitle = !widget.read ? "New Comment" : "Comment";
          notifType = "commented on your video";
        });
        break;
      case "follow":
        setState(() {
          notifTitle = !widget.read ? "New Follower" : "Follower";
          notifType = "started following you";
        });
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Material(
          color: AppTheme.primaryColor,
          child: StreamBuilder(
            stream: getNotif(),
            builder: (context, snap) {
              if (!snap.hasData ||
                  snap.connectionState == ConnectionState.waiting) {
                return LoadingCards(
                  count: 1,
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
                                    ))).then((value) => widget.onTap());
                        break;
                      case "follow":
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => SearchProfile(
                                      uid: widget.from,
                                    ))).then((value) => widget.onTap());
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
                    style: TextStyle(
                        color: AppTheme.pureWhiteColor,
                        fontWeight:
                            !widget.read ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              );
            },
          )),
    );
  }
}
