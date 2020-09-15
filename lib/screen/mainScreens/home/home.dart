import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/database/firestore_api.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/screen/mainScreens/home/postCard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<VideoInfo> _videos = <VideoInfo>[];
  double _widthOne;
  double _heightOne;
  UserInfoStore _userInfoStore = UserInfoStore();
  List _usersDetails = [];
  PopupMenu menu;
  GlobalKey btnKey = GlobalKey();
  UserAuth _userAuth = UserAuth();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _widthOne = size.width * 0.0008;
    _heightOne = (size.height * 0.007) / 5;
    return StreamBuilder(
      stream: _userInfoStore.getFollowing(
        uid: _userAuth.user.uid
      ),
      builder: (context, data){
        if (!data.hasData) {
          return Center(
            child: SpinKitCircle(
              color: Colors.orange,
              size: 60,
            ),
          );
        }else{
          if(data.data.documents.length == 0){
            return Center(
              child: Text(
                "Start following creators to see videos",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
            );
          }else{
            return StreamBuilder(
                stream: UserVideoStore().getFollowingVideos(
                  followings: data.data.documents
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SpinKitCircle(
                        color: Colors.orange,
                        size: 60,
                      ),
                    );
                  }else{
                    if(snapshot.data.documents.length == 0){
                      return Center(
                        child: Text(
                          "No videos to show",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }else{
                      return Center(
                          child: ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index){
                              return FutureBuilder(
                                future: _userInfoStore.getUserInfo(uid: snapshot.data.documents[index].data()['uploaderUid']),
                                builder: (context, snap){
                                  if(
                                  snap.connectionState ==
                                      ConnectionState.none || !snap.hasData
                                  ){
                                    return Container();
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: _widthOne * 50,
                                        vertical: _heightOne * 20
                                    ),
                                    child: PostCard(
                                        video: snapshot.data.documents[index],
                                        id: snapshot.data.documents[index].id,
                                        thumbnail: snapshot.data.documents[index].data()['thumbUrl'],
                                        profileImg: snap.data.data()['photoUrl'] == null ?
                                        "https://via.placeholder.com/150"
                                            : snap.data.data()['photoUrl'],
                                        title: snapshot.data.documents[index].data()['videoName'],
                                        uploader: snap.data.data()['username'],
                                        likeCount: snapshot.data.documents[index].data()['likes'],
                                        commentCount: snapshot.data.documents[index].data()['comments'],
                                        uploadTime: formatDateTime(snapshot.data.documents[index].data()['uploadedAt']),
                                        viewCount: snapshot.data.documents[index].data()['views'],
                                        rating: snapshot.data.documents[index].data()['rating']
                                    ),
                                  );
                                },
                              );
                            },
                          )
                      );
                    }
                  }
                }
            );
          }
        }
      }
    );
  }

  String formatDateTime(int millisecondsSinceEpoch){
    DateTime uploadTimeStamp =
    DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String sentAt = uploadTimeStamp.toString();
    Duration difference = DateTime.now().difference(DateTime.parse(sentAt));

    if(difference.inDays > 0){
      if(difference.inDays > 365){
        sentAt = (difference.inDays / 365).floor().toString() + ' years ago';
      }
      if(difference.inDays > 30 && difference.inDays < 365){
        sentAt = (difference.inDays / 30).floor().toString() + ' months ago';
      }
      if(difference.inDays >=1 && difference.inDays < 305){
        sentAt = difference.inDays.floor().toString() + ' days ago';
      }
    }
    else if(difference.inHours > 0){
      sentAt = difference.inHours.toString() + ' hours ago';
    }
    else if(difference.inMinutes > 0){
      sentAt = difference.inMinutes.toString() + ' mins ago';
    }
    else{
      sentAt = difference.inSeconds.toString() + ' secs';
    }

    return sentAt;
  }

  void getUsersDetails() async {
    for (int i = 0; i < _videos.length; i++) {
      print( "vid" + _videos[i].uploaderUid.toString());
      dynamic result = await _userInfoStore.getUserInfo(uid: _videos[i].uploaderUid);
      print(result.data());
      if(result != null){
        _usersDetails.add(UserDataModel.fromDocument(result));
      }else{
        _usersDetails.add(null);
      }
    }

    setState(() {});
  }
}
