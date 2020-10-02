import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/userDataModel.dart';

class CommentsScreen extends StatefulWidget {
  final String videoId;

  CommentsScreen({this.videoId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController controller = new TextEditingController();
  UserVideoStore _userVideoStore = UserVideoStore();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserDataModel _userDataModel = UserDataModel();
  String _comment = "";
  double _heightOne;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  Size _size;

  void setup() async{
    _userDataModel = UserDataModel.fromDocument(
      await _userInfoStore.getUserInfo(
          uid: UserAuth().user.uid
      )
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if(_userDataModel.username == null){
      setup();
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: _heightOne * 20),
          height: _size.height,
          color: Colors.orange,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  bottom: _heightOne * 20,
                  top: _heightOne * 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _widthOne * 50,),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                        child: Text(
                          "Comments",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _fontOne * 25,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(top: _heightOne * 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                          )
                      ),
                    child: getComments(),
                  )
              ),
              Container(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(bottom: 0),
                height: 70,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: _widthOne * 15,),
                    CircleAvatar(
                      radius: _iconOne * 18,
                      backgroundImage: NetworkImage(
                        _userDataModel.photoUrl == null ?
                        "https://via.placeholder.com/150" :
                        _userDataModel.photoUrl,
                      ),
                    ),
                    SizedBox(width: _widthOne * 25,),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (val){
                          _comment = val;
                        },
                        decoration: InputDecoration.collapsed(
                          hintText: 'Post a comment..',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 25,
                      color:  Colors.orange,
                      onPressed: () async{
                        if(_comment.isEmpty || _comment.replaceAll(" ", "").length == 0){
                          return;
                        }
                        await _userVideoStore.addVideoComments(
                          videoID: widget.videoId,
                          comment: _comment,
                        );
                        setState(() {
                          controller.clear();
                          _comment = "";
                        });
                      },
                    ),
                  ],
                ),
              )
            ],
          )
      ),
    );
  }

  Widget getComments(){
    return StreamBuilder(
      stream: _userVideoStore.getVideoComments(
        videoID: widget.videoId,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SpinKitCircle(
              color: Colors.orange,
              size: _fontOne * 60,
            ),
          );
        }else{
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) => showComment(
              userID: snapshot.data.documents[index].data()["userUID"],
              timestamp: snapshot.data.documents[index].data()["timestamp"],
              comment:  snapshot.data.documents[index].data()["comment"]
            ),
            itemCount: snapshot.data.documents.length,
          );
        }
      }
    );
  }

  Widget showComment({String userID, int timestamp, String comment}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
          future: _userInfoStore.getUserInfo(
            uid: userID
          ),
        builder: (context, snapshot){
            if(!snapshot.hasData){
              return Container();
            }else{
              return Row(
                children: [
                  CircleAvatar(
                    radius: _iconOne * 20,
                    backgroundImage: NetworkImage(
                        snapshot.data.data()["photoUrl"] == null ?
                        "https://via.placeholder.com/150" :
                        snapshot.data.data()["photoUrl"],
                    ),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            snapshot.data.data()["username"] + " \u2022 ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: _fontOne * 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            formatDateTime(timestamp),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: _fontOne * 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: _heightOne * 5,),
                      Text(
                        comment,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: _fontOne * 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              );
            }
        },
      ),
    );
  }

  String formatDateTime(int millisecondsSinceEpoch){
    DateTime uploadTimeStamp =
    DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String sentAt = uploadTimeStamp.toString();
    Duration difference = DateTime.now().difference(DateTime.parse(sentAt));

    if(difference.inDays > 0){
      if(difference.inDays > 365){
        sentAt = (difference.inDays / 365).floor().toString() + ' years';
      }
      if(difference.inDays > 30 && difference.inDays < 365){
        sentAt = (difference.inDays / 30).floor().toString() + ' months';
      }
      if(difference.inDays >=1 && difference.inDays < 305){
        sentAt = difference.inDays.floor().toString() + ' days';
      }
    }
    else if(difference.inHours > 0){
      sentAt = difference.inHours.toString() + ' hours';
    }
    else if(difference.inMinutes > 0){
      sentAt = difference.inMinutes.toString() + ' mins';
    }
    else{
      sentAt = difference.inSeconds.toString() + ' secs';
    }

    return sentAt;
  }
}
