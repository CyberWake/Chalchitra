import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wowtalent/data/user_json.dart';
import 'package:wowtalent/theme/colors.dart';

double _heightOne;
double _widthOne;
double _fontOne;
double _iconOne;
Size _size;

class ChatDetailPage extends StatefulWidget {
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
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
                      "Tyler Nix",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontOne * 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                          color: online,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38)),
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
                      child: getBody()
                  )
              ),
            ],
          )
      ),
      bottomSheet: getBottom(),
    );
  }

  Widget getBottom() {
    return Container(
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget getBody() {
    return ListView(
      padding: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 80),
      children: List.generate(messages.length, (index) {
        return ChatBubble(
            isMe: messages[index]['isMe'],
            messageType: messages[index]['messageType'],
            message: messages[index]['message'],
            profileImg: messages[index]['profileImg']);
      }),
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
