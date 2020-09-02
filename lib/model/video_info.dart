class VideoInfo {
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String videoName;
  int likes;
  int shares;
  int rating;
  int comments;

  VideoInfo(
      {this.videoUrl,
      this.thumbUrl,
      this.coverUrl,
      this.aspectRatio,
      this.uploadedAt,
      this.videoName,
      this.likes,
      this.shares,
      this.rating,
      this.comments});
}
