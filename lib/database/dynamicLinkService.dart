import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/videoInfoModel.dart';

class DynamicLinkService {
  UserVideoStore getVideoInfo = UserVideoStore();
  VideoInfo video = VideoInfo();
  List<VideoInfo> videos = [];
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
      print('Video Id:        ${linkVideoInfo['videoId']}');
      video = await getVideoInfo.getSharedLinkVideo(
          videoId: linkVideoInfo['videoId']);
      print("DeepLink data " + video.videoUrl);
      videos.add(video);
      return true;
    } else {
      return false;
    }
  }
}
