import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/video_info.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseProvider {
  static saveVideo(VideoInfo video) async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    String uid = firebaseUser.uid;
    await Firestore.instance
        .collection('feedVideos')
        .document(uid)
        .collection('videos')
        .document()
        .setData({
      'videoUrl': video.videoUrl,
      'thumbUrl': video.thumbUrl,
      'coverUrl': video.coverUrl,
      'aspectRatio': video.aspectRatio,
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    });

    await Firestore.instance.collection('videos').document().setData({
      'videoUrl': video.videoUrl,
      'thumbUrl': video.thumbUrl,
      'coverUrl': video.coverUrl,
      'aspectRatio': video.aspectRatio,
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    });
  }

  static listenToVideos(callback) async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    String uid = firebaseUser.uid;
    Firestore.instance
        .collection('feedVideos')
        .document(uid)
        .collection('videos')
        .snapshots()
        .listen((qs) {
      final videos = mapQueryToVideoInfo(qs);
      callback(videos);
    });

  }

  static listenToAllVideos(callback) async{
    Firestore.instance
        .collection('videos')
        .snapshots()
        .listen((qs) {
      final videos = mapQueryToVideoInfo(qs);
      callback(videos);
      print(videos);
      });
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    return qs.documents.map((DocumentSnapshot ds) {
      return VideoInfo(
        videoUrl: ds.data['videoUrl'],
        thumbUrl: ds.data['thumbUrl'],
        coverUrl: ds.data['coverUrl'],
        aspectRatio: ds.data['aspectRatio'],
        videoName: ds.data['videoName'],
        uploadedAt: ds.data['uploadedAt'],
      );
    }).toList();
  }
}
