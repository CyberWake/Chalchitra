import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/userDataModel.dart';

import '../auth/userAuth.dart';
import '../model/videoInfoModel.dart';

class UserVideoStore {
  static final CollectionReference _feedVideos =
      FirebaseFirestore.instance.collection('feedVideos');

  static final CollectionReference _users =
      FirebaseFirestore.instance.collection('WowUsers');

  static final CollectionReference _allVideos =
      FirebaseFirestore.instance.collection('videos');

  static final CollectionReference _videoLikes =
      FirebaseFirestore.instance.collection('videoLikes');

  static final CollectionReference _videoWatched =
      FirebaseFirestore.instance.collection('videoWatched');

  static final CollectionReference _videoComments =
      FirebaseFirestore.instance.collection('videoComments');

  static final CollectionReference _videoRating =
      FirebaseFirestore.instance.collection('ratings');

  static final CollectionReference _totalVideoRating =
      FirebaseFirestore.instance.collection('totalratings');

  static final CollectionReference _videoDrafts =
      FirebaseFirestore.instance.collection('videoDrafts');

  static final _notificationCenter =
      FirebaseFirestore.instance.collection("notifications");

  static final UserAuth _userAuth = UserAuth();

  static saveVideo(VideoInfo video) async {
    try {
      // Get Current User
      //String uid = _userAuth.user.uid;
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
        'uploaderName': video.uploaderName,
        'uploaderPic': video.uploaderPic,
        'average' : video.average,
      };
      await _allVideos.doc().set(videoData);
      await _users
          .doc(_userAuth.user.uid)
          .update({"videoCount": FieldValue.increment(1)});
    } catch (e) {
      print(e.toString());
    }
  }

  static saveVideoDraft(VideoInfo video) async {
    try {
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
        'uploaderName': video.uploaderName,
        'uploaderPic': video.uploaderPic,
        'average' : video.average,
      };

      await _videoDrafts.doc().set(videoData);
    } catch (e) {
      print(e.toString());
    }
  }

  static deleteVideoDraft(VideoInfo video) async {
    try {
      await _videoDrafts.doc(video.videoId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  static deleteUploadedVideo(VideoInfo video, context) async {
    try {
      await _users
          .doc(_userAuth.user.uid)
          .update({"videoCount": FieldValue.increment(-1)});
      await _allVideos.doc(video.videoId).delete();
      await _videoComments.doc(video.videoId).delete();
      await removeLike(video);
      await removeRating(video);
      await removeWatchHistory(video);
      await deleteNotif(video);
    } catch (e) {
      print(e.toString());
    }
    UserDataModel userData =
        await UserInfoStore().getUserInformation(uid: _userAuth.user.uid);
    Provider.of<CurrentUser>(context, listen: false)
        .updateCurrentUser(userData);
  }

  static removeLike(VideoInfo video) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      return _videoLikes.get().then((value) => value.docs.forEach((element) {
            element.reference
                .collection("likedVideos")
                .where("id", isEqualTo: video.videoId)
                .get()
                .then((value) {
              if (value.docs.isEmpty) {
              } else {
                value.docs.forEach((element) {
                  batch.delete(element.reference);
                });
                return batch.commit();
              }
            });
          }));
    } catch (e) {
      print(e.toString());
    }
  }

  static removeWatchHistory(VideoInfo video) {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      return _videoWatched.get().then((value) => value.docs.forEach((element) {
            element.reference
                .collection("viewedVideos")
                .where("id", isEqualTo: video.videoId)
                .get()
                .then((value) {
              if (value.docs.isEmpty) {
              } else {
                value.docs.forEach((element) {
                  batch.delete(element.reference);
                });
                return batch.commit();
              }
            });
          }));
    } catch (e) {
      print(e.toString());
    }
  }

  static removeRating(VideoInfo video) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      return _videoRating.get().then((value) => value.docs.forEach((element) {
            element.reference.collection(video.videoId).get().then((value) {
              value.docs.forEach((element) {
                batch.delete(element.reference);
              });
              return batch.commit();
            });
          }));
    } catch (e) {
      print(e.toString());
    }
  }

  static deleteNotif(VideoInfo video) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      return _notificationCenter
          .doc(_userAuth.user.uid)
          .collection("notifs")
          .where("videoID", isEqualTo: video.videoId)
          .get()
          .then((value) {
        print(value.docs[0]);
        value.docs.forEach((element) {
          batch.delete(element.reference);
        });
        return batch.commit();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<VideoInfo> getVideoInfo({String videoid}) async {
    try {
      var doc = await _allVideos.doc(videoid).get();
      return VideoInfo.fromDocument(doc);
    } catch (e) {
      print(e.toString());
    }
  }

  Future getDraftVideos({String uid}) async {
    try {
      QuerySnapshot qs =
          await _videoDrafts.where('uploaderUid', isEqualTo: uid).get();
      return mapQueryToVideoInfo(qs);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static listenToVideos(callback, String uid) async {
    print(uid + ' firestore');
    try {
      _allVideos.where('uploaderUid', isEqualTo: uid).snapshots().listen((qs) {
        final videos = mapQueryToVideoInfo(qs);
        callback(videos);
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future getProfileVideos({String uid}) async {
    try {
      QuerySnapshot qs =
          await _allVideos.where('uploaderUid', isEqualTo: uid).get();
      return mapQueryToVideoInfo(qs);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<VideoInfo> getSharedLinkVideo({String videoId}) async {
    try {
      DocumentSnapshot ds = await _allVideos.doc(videoId).get();
      return mapDocumentToVideoInfo(ds);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<VideoInfo> getLikedVideo({String videoId}) async {
    try {
      DocumentSnapshot ds = await _allVideos.doc(videoId).get();
      return mapDocumentToVideoInfo(ds);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream getVideos() {
    return _allVideos.orderBy("uploadedAt", descending: true).snapshots();
  }

  Future getFollowingVideos({List<DocumentSnapshot> followings}) {
    return _allVideos
        .where('uploaderUid',
            whereIn: List.generate(followings.length, (index) {
              return followings[index].id;
            }))
        .orderBy("uploadedAt", descending: true)
        .limit(50)
        .get();
  }

  static listenToAllVideos(callback) async {
    try {
      _allVideos.orderBy("likes", descending: false).snapshots().listen((qs) {
        final videos = mapQueryToVideoInfo(qs);
        callback(videos);
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static listenTopVideos(callback) async {
    try {
      _allVideos
          .orderBy("views", descending: false)
          .limit(10)
          .snapshots()
          .listen((qs) {
        final videos = mapQueryToVideoInfo(qs);
        callback(videos);
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static listenToCategoryVideos(callback, String videoCategoryPage) async {
    try {
      _allVideos
          .where('category', isEqualTo: videoCategoryPage)
          .orderBy("uploadedAt", descending: true)
          .snapshots()
          .listen((qs) {
        final videos = mapQueryToVideoInfo(qs);
        callback(videos);
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    try {
      return qs.docs.map((DocumentSnapshot ds) {
        return VideoInfo(
            // rating: ds.data()['rating'],
            videoUrl: ds.data()['videoUrl'],
            videoHashtag: ds.data()['videoHashtag'],
            thumbUrl: ds.data()['thumbUrl'],
            coverUrl: ds.data()['coverUrl'],
            aspectRatio: ds.data()['aspectRatio'].toDouble(),
            videoName: ds.data()['videoName'],
            category: ds.data()['category'],
            uploadedAt: ds.data()['uploadedAt'],
            uploaderUid: ds.data()['uploaderUid'],
            likes: ds.data()['likes'],
            comments: ds.data()['comments'],
            videoId: ds.id,
            uploaderName: ds.data()['uploaderName'],
            uploaderPic: ds.data()['uploaderPic'],
            views: ds.data()['views'],
            average: ds.data()['average'],
          );
      }).toList();
    } catch (e) {
      print(e.toString());
    }
  }

  static mapDocumentToVideoInfo(DocumentSnapshot ds) {
    try {
      return VideoInfo(
          videoUrl: ds.data()['videoUrl'],
          videoHashtag: ds.data()['videoHashtag'],
          thumbUrl: ds.data()['thumbUrl'],
          coverUrl: ds.data()['coverUrl'],
          aspectRatio: ds.data()['aspectRatio'],
          videoName: ds.data()['videoName'],
          category: ds.data()['category'],
          uploadedAt: ds.data()['uploadedAt'],
          uploaderUid: ds.data()['uploaderUid'],
          likes: ds.data()['likes'],
          comments: ds.data()['comments'],
          videoId: ds.id,
          uploaderName: ds.data()['uploaderName'],
          uploaderPic: ds.data()['uploaderPic'],
          views: ds.data()['views'],
          average: ds.data()['average'],
        );
    } catch (e) {
      print(e.toString());
    }
  }

  Future likeVideo({String videoID}) async {
    try {
      await _allVideos.doc(videoID).update({"likes": FieldValue.increment(1)});
      await _videoLikes
          .doc(_userAuth.user.uid)
          .collection("likedVideos")
          .doc(videoID)
          .set({"id": videoID});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future increaseVideoCount({String videoID}) async {
    try {
      await _allVideos.doc(videoID).update({"views": FieldValue.increment(1)});
      await _videoWatched
          .doc(_userAuth.user.uid)
          .collection("viewedVideos")
          .doc(videoID)
          .set({"id": videoID});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future dislikeVideo({String videoID}) async {
    try {
      await _allVideos.doc(videoID).update({"likes": FieldValue.increment(-1)});
      await _videoLikes
          .doc(_userAuth.user.uid)
          .collection("likedVideos")
          .doc(videoID)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future rateVideo({String videoID, double newRating}) async {
    double oldRating;
    try {
      await _videoRating
          .doc(_userAuth.user.uid)
          .collection(videoID)
          .doc(videoID)
          .set({'videoID': videoID, 'rating': newRating});

      //total video rating
      await _totalVideoRating
          .doc(videoID)
          .update({_userAuth.user.uid: newRating});

      //finds total rating and number of people rated
      DocumentSnapshot result = await _totalVideoRating.doc(videoID).get();
      var totalRatings = result.data().values.toList();
      var sum = 0.0;
      for (var i = 0; i < totalRatings.length; i++) {
        sum += totalRatings[i];
      }
      
      //finds average rating
      var averageRating = sum / totalRatings.length;

      //update videoInfo model data
      await _allVideos
          .doc(videoID)
          .update({"average": averageRating});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future checkRated({String videoID}) async {
    try {
      QuerySnapshot res = await _videoRating
          .doc(_userAuth.user.uid)
          .collection(videoID)
          .where("videoID", isEqualTo: videoID)
          .get();
      // .doc(videoID)
      // .get();
      if (res.size == 0) {
        return 0.0;
      } else {
        print(res.docs[0].data()['rating']);
        return res.docs[0].data()['rating'];
      }
    } catch (e) {
      print(e.toString());
      return 0.0;
    }
  }

  Future checkLiked({String videoID}) async {
    try {
      QuerySnapshot res = await _videoLikes
          .doc(_userAuth.user.uid)
          .collection("likedVideos")
          .where("id", isEqualTo: videoID)
          .get();
      return res.size == 1;
    } catch (e) {
      return false;
    }
  }

  Future totalRating({String videoID}) async {
    print('res : called');
    try {
      QuerySnapshot res = await _videoRating
          .doc(_userAuth.user.uid)
          .collection(videoID)
          .where("videoID", isEqualTo: videoID)
          .get();
      double rating = res.docs[0].data()['rating'];
      print("res: $rating");
      return res.size == 1;
    } catch (e) {
      return false;
    }
  }

  Future checkWatched({String videoID}) async {
    try {
      QuerySnapshot res = await _videoWatched
          .doc(_userAuth.user.uid)
          .collection("viewedVideos")
          .where("id", isEqualTo: videoID)
          .get();
      print("res.size: ${res.size}");
      return res.size == 1;
    } catch (e) {
      return false;
    }
  }

  Future addVideoComments({String videoID, String comment}) async {
    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      await _allVideos
          .doc(videoID)
          .update({"comments": FieldValue.increment(1)});
      await _videoComments
          .doc(videoID)
          .collection(videoID)
          .doc(timestamp.toString())
          .set(
        {
          "userUID": _userAuth.user.uid,
          "comment": comment,
          "timestamp": timestamp
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream getVideoComments({String videoID}) {
    return _videoComments
        .doc(videoID)
        .collection(videoID)
        .orderBy("timestamp", descending: true)
        .limit(50)
        .snapshots();
  }

  Future getComments({String id}) async {
    final query = await _videoComments.doc(id).collection(id).get();
    return query;
  }

  Future updateVideoInfo(
      {String id, String vidName, String hashTag, String category}) async {
    try {
      await _allVideos.doc(id).update({
        'videoName': vidName,
        'videoHashtag': hashTag,
        'category': category,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  searchByHashtag(String hash) {
    return _allVideos
        .where("videoHashtag", isGreaterThanOrEqualTo: hash.substring(0, 1))
        .get();
  }
}
