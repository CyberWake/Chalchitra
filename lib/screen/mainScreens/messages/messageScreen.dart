import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/database/firestore_api.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/screen/mainScreens/messages/messagesChatScreen.dart';
import 'package:wowtalent/data/user_json.dart';
import 'package:wowtalent/shared/formFormatting.dart';

class Message extends StatefulWidget {
  Message({Key key}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  double _heightOne;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  UserInfoStore _userInfoStore = UserInfoStore();
  List _usersDetails = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: _heightOne * 20),
          height: _size.height,
          color: Colors.orange,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
          padding: EdgeInsets.only(
            bottom: _heightOne * 20,
            top: _heightOne * 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: _widthOne * 50,
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(child: Container()),
              Text(
                "Messages",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontOne * 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: _widthOne * 100,
              )
            ],
          ),
        ),
              Container(
                width: _size.width * 0.8,
                height: _heightOne * 42.5,
                margin: EdgeInsets.only(
                  bottom: _heightOne * 20,
                ),
                padding: EdgeInsets.all(_iconOne * 5),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: TextFormField(
                  decoration: authInputFormatting.copyWith(
                      hintText: "Search Conversations"),
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
                        )),
                    child: getBody()),
              ),
            ]
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return StreamBuilder(
      stream: _userInfoStore.getChats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SpinKitCircle(
              color: Colors.orange,
              size: _fontOne * 60,
            ),
          );
        } else {
          if(snapshot.data.data() == null){
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: _fontOne * 16,
                ),
              ),
            );
          }
          List keys = snapshot.data.data().keys.toList();
          List values = snapshot.data.data().values.toList();
          getUsersDetails(values);
          if (keys.isEmpty) {
            return Center(
              child: Text(
                "No chats found",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: _fontOne * 16,
                ),
              ),
            );
          } else if (_usersDetails.length < keys.length) {
            return Center(
              child: SpinKitCircle(
                color: Colors.orange,
                size: _fontOne * 60,
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
               if(_usersDetails[index] == null){
                 return Container();
               }else{
                 return InkWell(
                   onTap: () {
                     Navigator.push(
                         context,
                         MaterialPageRoute(
                             builder: (_) => ChatDetailPage(
                               targetUID: values[index],
                             )));
                   },
                   child: Padding(
                     padding: const EdgeInsets.only(bottom: 20, left: 10),
                     child: Row(
                         children: <Widget>[
                           Container(
                               width: 75,
                               height: 75,
                               child: Container(
                                 decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(3),
                                   child: Container(
                                       width: 75,
                                       height: 75,
                                       decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           image: DecorationImage(
                                               image: NetworkImage(
                                                   _usersDetails[index].photoUrl == null
                                                       ? "https://via.placeholder.com/150"
                                                       : _usersDetails[index].photoUrl
                                               ),
                                               fit: BoxFit.cover)
                                       )
                                   ),
                                 ),
                               )),
                           SizedBox(
                             width: 20,
                           ),
                           StreamBuilder(
                             stream: _userInfoStore.getLastMessage(
                               targetUID: values[index],
                             ),
                             builder: (context, snapshot) {
                               return Row(
                                 children: [
                                   Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: <Widget>[
                                         Text(
                                           _usersDetails[index].username,
                                           style: TextStyle(
                                               fontSize: 17,
                                               fontWeight: FontWeight.w500
                                           ),
                                         ),
                                         SizedBox(
                                           height: 5,
                                         ),
                                         SizedBox(
                                           width: _size.width * 0.45,
                                           child: Text(
                                             snapshot.hasData ?
                                             snapshot.data
                                                 .documents[0].data()['message']
                                                 : ".....",
                                             style: TextStyle(
                                                 fontSize: _fontOne * 13,
                                                 color: Colors.black.withOpacity(0.6)
                                             ),
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         )
                                       ]),
                                   SizedBox(
                                     width: _widthOne * 40,
                                   ),
                                   Text(
                                     snapshot.hasData ?
                                     formatDateTime(
                                         snapshot
                                             .data
                                             .documents[0]
                                             .data()['timestamp']
                                     ) : ".....",
                                     style: TextStyle(
                                         color: Colors.grey,
                                         fontSize: _fontOne * 12
                                     ),
                                   ),
                                   SizedBox(
                                     width: _widthOne * 20,
                                   )
                                 ],
                               );
                             }
                           )
                     ]),
                   ),
                 );
               }
              },
              itemCount: snapshot.data.data().length,
              reverse: true,
              //controller: listScrollController,
            );
          }
        }
      },
    );
  }

  void getUsersDetails(List uIDs) async {
    for (int i = 0; i < uIDs.length; i++) {
      dynamic result = await _userInfoStore.getUserInfo(uid: uIDs[i]);
      _usersDetails.add(UserDataModel.fromDocument(result));
    }

    setState(() {});
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
