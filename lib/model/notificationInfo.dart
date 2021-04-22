import 'package:Chalchitra/imports.dart';

class NotifInfo {
  UserDataModel user;
  VideoInfo video;

  NotifInfo({this.user, this.video});

  UserDataModel get userInfo => this.user;
  VideoInfo get vidInfo => this.video;
  set userInfo(UserDataModel _user) => this.user = _user;

  set vidInfo(VideoInfo _vid) => this.video = _vid;
}
