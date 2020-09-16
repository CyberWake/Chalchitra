import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../auth/auth_api.dart';
import '../model/video_info.dart';

class UserVideoStore {
  static final CollectionReference _feedVideos =
  FirebaseFirestore.instance.collection('feedVideos');

  static final CollectionReference _allVideos =
  FirebaseFirestore.instance.collection('videos');

  static final CollectionReference _videoLikes =
  FirebaseFirestore.instance.collection('videoLikes');

  static final CollectionReference _videoComments =
  FirebaseFirestore.instance.collection('videoComments');

  static final CollectionReference _videoRating =
  FirebaseFirestore.instance.collection('ratings');

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
        'videoHashtag': video.videoHashtag,
        'category': video.category,
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

  static listenToVideos(callback,String uid) async {
    print(uid+' firestore');
    try{
      _allVideos
          .where('uploaderUid', isEqualTo: uid)
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
    return _allVideos.orderBy("uploadedAt", descending: true)
        .snapshots();
  }

  Stream getFollowingVideos({List<DocumentSnapshot> followings}){
    return _allVideos
        .where('uploaderUid',
        whereIn: List.generate(followings.length, (index){
          return followings[index].id;
        }))
        .orderBy("uploadedAt", descending: true)
        .limit(100)
        .snapshots();
  }

  static listenToAllVideos(callback) async{
    try{
      _allVideos.orderBy("uploadedAt", descending: true)
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
  static listenToCategoryVideos(callback,String videoCategoryPage) async{
    try{
      _allVideos.where('category' ,isEqualTo: videoCategoryPage)
          .orderBy("uploadedAt", descending: true)
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
          category: ds.data()['category'],
          uploadedAt: ds.data()['uploadedAt'],
          uploaderUid: ds.data()['uploaderUid'],
          likes: ds.data()['likes'],
          comments: ds.data()['comments'],
          videoId: ds.id
        );
      }).toList();
    }catch(e){
      print(e.toString());
    }
  }

  Future likeVideo({String videoID}) async{
    try{
      await _allVideos.doc(videoID).update(
        {"likes" : FieldValue.increment(1)}
      );
      await _videoLikes.doc(_userAuth.user.uid)
          .collection("likedVideos").doc(videoID).set({
        "id" : videoID
      });
      return true;
    }catch(e){
      return false;
    }
  }

  Future dislikeVideo({String videoID}) async{
    try{
      await _allVideos.doc(videoID).update(
          {"likes" : FieldValue.increment(-1)}
      );
      await _videoLikes.doc(_userAuth.user.uid)
          .collection("likedVideos").doc(videoID).delete();
      return true;
    }catch(e){
      return false;
    }
  }

  Future rateVideo({String videoID,double rating}) async{
    try{
      await _videoRating
          .doc(_userAuth.user.uid)
          .collection(videoID)
          .doc(videoID)
          .set({
        'videoID': videoID,
        'rating': rating});
      return true;
    }catch(e){
      return false;
    }
  }

  Future checkRated({String videoID}) async{
    try{
      QuerySnapshot res = await _videoRating.doc(_userAuth.user.uid)
          .collection(videoID).where(
          "videoID", isEqualTo: videoID
      ).get();
      if(res.size==0){
        return 0.0;
      }
      else{
        return res.docs[0].data()['rating'];
      }
    }catch(e){
      return false;
    }
  }

  Future checkLiked({String videoID}) async{
    try{
      QuerySnapshot res = await _videoLikes.doc(_userAuth.user.uid)
          .collection("likedVideos").where(
          "id", isEqualTo: videoID
      ).get();
      return res.size == 1;
    }catch(e){
      return false;
    }
  }

  Future addVideoComments({String videoID, String comment}) async{
    try{
      int timestamp =  DateTime.now().millisecondsSinceEpoch;
      await _allVideos.doc(videoID).update({
          "comments" : FieldValue.increment(1)
        });
      await _videoComments
          .doc(videoID).collection(videoID).doc(timestamp.toString())
          .set({
        "userUID" : _userAuth.user.uid,
        "comment" : comment,
        "timestamp": timestamp
      },);
      return true;
    }catch(e){
      return false;
    }
  }

  Stream getVideoComments({String videoID}) {
    return _videoComments.doc(videoID).collection(videoID)
        .orderBy("timestamp", descending: true)
        .limit(50).snapshots();
  }
}
