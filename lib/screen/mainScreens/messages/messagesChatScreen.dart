import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/theme/colors.dart';

double _heightOne;
double _widthOne;
double _fontOne;
double _iconOne;
Size _size;

class ChatDetailPage extends StatefulWidget {
  final String targetUID;
  ChatDetailPage({this.targetUID});
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  UserDataModel _userDataModel = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  bool _loading = true;
  final TextEditingController controller = new TextEditingController();
  bool _checkChatAlreadyAdded = true;
  void setup() async{
    await _userInfoStore.getUserInfoStream(
      uid: widget.targetUID
    ).first.then((document){
      _userDataModel = UserDataModel.fromDocument(document);
    });


    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setup();
  }
  String text = "";

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
                    Expanded(child: Container()),
                    Text(
                      _loading ?  " " : _userDataModel.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontOne * 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Container()),
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: _iconOne * 25,
                      backgroundImage: CachedNetworkImageProvider(
                        _userDataModel.photoUrl == null ?
                        'https://via.placeholder.com/150' :
                            _userDataModel.photoUrl
                      ),
                    ),
                    SizedBox(width: _widthOne * 100,)
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
                      child: _loading ? Center(
                        child: SpinKitCircle(
                          color: Colors.orange,
                          size: _fontOne * 60,
                        ),
                      ): getBody()
                  )
              ),
              Container(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(bottom: 0),
                height: 70,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.photo),
                      iconSize: 25,
                      color: Colors.orange,
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (val){
                          text = val;
                        },
                        decoration: InputDecoration.collapsed(
                          hintText: 'Send a message..',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 25,
                      color:  Colors.orange,
                      onPressed: () async{
                        if(text.isEmpty || text.replaceAll(" ", "").length == 0){
                          return;
                        }

                        if(_checkChatAlreadyAdded){
                          await _userInfoStore.checkChatExists(
                              targetUID: widget.targetUID
                          ).then((value) async{
                            print(value);
                            if(value == false){
                              await _userInfoStore.addChatSender(
                                  targetUID: widget.targetUID
                              );
                              await _userInfoStore.addChatReceiver(
                                  targetUID: widget.targetUID
                              );
                            }
                          });
                          _checkChatAlreadyAdded = false;
                        }

                        await _userInfoStore.sendMessage(
                          targetUID: widget.targetUID,
                          message: text,
                        );
                        controller.clear();
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

  Widget getBody() {
    return StreamBuilder(
      stream: _userInfoStore.getChatDetails(
        targetUID: widget.targetUID,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: SpinKitCircle(
                color: Colors.orange,
                size: _fontOne * 60,
              ),
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) => ChatBubble(
              isMe: snapshot.data.documents[index].data()["reciever"] == widget.targetUID,
              messageType: 1,
              message: snapshot.data.documents[index].data()['message'],
              profileImg: _userDataModel.photoUrl == null ?
              'https://via.placeholder.com/150' : _userDataModel.photoUrl
            ),
            itemCount: snapshot.data.documents.length,
            reverse: true,
          );
        }
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String profileImg;
  final String message;
  final int messageType;
  const ChatBubble({
    Key key,
    this.isMe,
    this.profileImg,
    this.message,
    this.messageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("message" + isMe.toString());
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: 5
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: getMessageType(messageType)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    message,
                    style: TextStyle(color: white, fontSize: 17),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: 5
      ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(profileImg), fit: BoxFit.cover)),
            ),
            SizedBox(
              width: 15,
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: getMessageType(messageType)),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    message,
                    style: TextStyle(color: black, fontSize: 17),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  getMessageType(messageType) {
    if (isMe) {
      // start message
      if (messageType == 1) {
        return BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // middle message
      else if (messageType == 2) {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // end message
      else if (messageType == 3) {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // standalone message
      else {
        return BorderRadius.all(Radius.circular(30));
      }
    }
    // for sender bubble
    else {
      // start message
      if (messageType == 1) {
        return BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // middle message
      else if (messageType == 2) {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // end message
      else if (messageType == 3) {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // standalone message
      else {
        return BorderRadius.all(Radius.circular(30));
      }
    }
  }

  _sendMessageArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25,
            color: primary,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message..',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
