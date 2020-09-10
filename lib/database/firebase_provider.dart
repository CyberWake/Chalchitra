import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../auth/auth_api.dart';
import '../model/video_info.dart';

class UserVideoStore {
  static final CollectionReference _feedVideos =
  FirebaseFirestore.instance.collection('feedVideos');

  static final CollectionReference _allVideos =
  FirebaseFirestore.instance.collection('videos');

  static final UserAuth _userAuth = UserAuth();


  static saveVideo(VideoInfo video) async {
    try{
      // Get Current User
      String uid = _userAuth.user.uid;

      // Map of video data to be added ot firestore
      Map<String, dynamic> videoData = {
        'videoUrl': video.videoUrl,
        'thumbUrl': video.thumbUrl,
        'coverUrl': video.coverUrl,
        'aspectRatio': video.aspectRatio,
        'uploadedAt': video.uploadedAt,
        'videoName': video.videoName,
        'uploaderUid': video.uploaderUid,
        'likes': video.likes,
        'views': video.views,
        'comments': video.comments,
        'rating': video.rating,
      };


      await _feedVideos
          .doc(uid)
          .collection('videos')
          .doc()
          .set(videoData);

      await _allVideos
          .doc()
          .set(videoData);

    }catch(e){
      print(e.toString());
    }
  }

  static listenToVideos(callback) async {
    try{
      String uid = _userAuth.user.uid;
      _feedVideos
          .doc(uid)
          .collection('videos')
          .snapshots()
          .listen((qs) {
        final videos = mapQueryToVideoInfo(qs);
        callback(videos);
      });
      return true;
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  Stream getVideos(){
    return _allVideos
        .snapshots();
  }

  static listenToAllVideos(callback) async{
    try{
      _allVideos
          .snapshots()
          .listen((qs) {
        final videos = mapQueryToVideoInfo(qs);
        callback(videos);
      });
      return true;
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    try{
      return qs.docs.map((DocumentSnapshot ds) {
        return VideoInfo(
          videoUrl: ds.data()['videoUrl'],
          thumbUrl: ds.data()['thumbUrl'],
          coverUrl: ds.data()['coverUrl'],
          aspectRatio: ds.data()['aspectRatio'],
          videoName: ds.data()['videoName'],
          uploadedAt: ds.data()['uploadedAt'],
        );
      }).toList();
    }catch(e){
      print(e.toString());
    }
  }
}
