import 'package:cloud_firestore/cloud_firestore.dart';

class VideoInfo {
  String uploaderUid;
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String videoName;
  String videoHashtag;
  String category;
  int views;
  int likes;
  int shares;
  int rating;
  int comments;
  String videoId;

  VideoInfo(
      {
        this.uploaderUid,
        this.videoUrl,
        this.thumbUrl,
        this.coverUrl,
        this.aspectRatio,
        this.uploadedAt,
        this.videoName,
        this.videoHashtag,
        this.category,
        this.views,
        this.likes,
        this.shares,
        this.rating,
        this.comments,
        this.videoId,
      });

  static fromDocument(QueryDocumentSnapshot ds) {
    return VideoInfo(
      uploaderUid: ds.data()['uploaderUid'],
      videoUrl: ds.data()['videoUrl'],
      thumbUrl: ds.data()['thumbUrl'],
      coverUrl: ds.data()['coverUrl'],
      rating: ds.data()['rating'],
      likes: ds.data()['likes'],
      comments: ds.data()['comments'],
      aspectRatio: ds.data()['aspectRatio'],
      videoHashtag: ds.data()['videoHashtag'],
      videoName: ds.data()['videoName'],
      uploadedAt: ds.data()['uploadedAt'],
      category: ds.data()['category'],
    );
  }
}
