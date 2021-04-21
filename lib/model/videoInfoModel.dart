import 'package:cloud_firestore/cloud_firestore.dart';

class VideoInfo {
  String uploaderUid;
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  String shareUrl;
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
  String uploaderName;
  String uploaderPic;
  double average;

  VideoInfo(
      {this.uploaderUid,
      this.videoUrl,
      this.thumbUrl,
      this.coverUrl,
      this.shareUrl,
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
      this.uploaderName,
      this.uploaderPic,
      this.average,
    });

  static fromDocument(DocumentSnapshot ds) {
    return VideoInfo(
      uploaderUid: ds.data()['uploaderUid'],
      videoUrl: ds.data()['videoUrl'],
      thumbUrl: ds.data()['thumbUrl'],
      coverUrl: ds.data()['coverUrl'],
      shareUrl: ds.data()['shareUrl'],
      rating: ds.data()['rating'],
      likes: ds.data()['likes'],
      comments: ds.data()['comments'],
      aspectRatio: ds.data()['aspectRatio'].toDouble(),
      videoHashtag: ds.data()['videoHashtag'],
      videoName: ds.data()['videoName'],
      uploadedAt: ds.data()['uploadedAt'],
      category: ds.data()['category'],
      views: ds.data()['views'],
      videoId: ds.id,
      uploaderName: ds.data()['uploaderName'],
      uploaderPic: ds.data()['uploaderPic'],
      average: ds.data()['average'],
    );
  }
}
