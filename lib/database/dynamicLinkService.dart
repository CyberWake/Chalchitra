import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';

class DynamicLinkService {
  UserVideoStore getVideoInfo = UserVideoStore();
  VideoInfo video = VideoInfo();
  Map<String, String> linkVideoInfo;
  bool isFromLink;

  Future handleDynamicLinks(context, bool replacement) async {
    print("in dynamic links");
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    isFromLink = await _handleDeepLink(data, replacement, context);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLinkData) async {
      isFromLink = await _handleDeepLink(dynamicLinkData, replacement, context);
    }, onError: (OnLinkErrorException e) async {
      print('Dynamic Link failed: ${e.message}');
    });
  }

  Future<bool> _handleDeepLink(
      PendingDynamicLinkData data, bool replacement, context) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      linkVideoInfo = deepLink.queryParameters;
      video = await getVideoInfo.getSharedLinkVideo(
          videoId: linkVideoInfo['videoId']);
      print("DeepLink data " + video.videoUrl);
      List<VideoInfo> _videos;
      _videos.add(video);
      if (replacement) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (context) => Player(
                      videos: _videos,
                      index: 0,
                    )));
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => Player(
                      videos: _videos,
                      index: 0,
                    )));
      }
      print("push done");
      return true;
    } else {
      return false;
    }
  }
}
