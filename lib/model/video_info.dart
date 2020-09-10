class VideoInfo {
  String uploaderUid;
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String videoName;
  int views;
  int likes;
  int shares;
  int rating;
  int comments;

  VideoInfo(
      {this.uploaderUid,
        this.videoUrl,
      this.thumbUrl,
      this.coverUrl,
      this.aspectRatio,
      this.uploadedAt,
      this.videoName,
      this.views,
      this.likes,
      this.shares,
      this.rating,
      this.comments});
}
