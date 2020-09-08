import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wowtalent/data/user_json.dart';
import 'package:wowtalent/theme/colors.dart';

class ChatDetailPage extends StatefulWidget {
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Hexcolor('#F29F05').withOpacity(0.2),
        elevation: 0,
        leading: FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: primary,
            )),
        title: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(
                          "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60"),
                      fit: BoxFit.cover)),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Tyler Nix",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: black),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "Active now",
                  style: TextStyle(color: black.withOpacity(0.4), fontSize: 14),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                    color: online,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38)),
              ),
            ),
          ],
        ),
      ),
      body: getBody(),
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
            color: Hexcolor('#F29F05'),
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
            color: Hexcolor('#F29F05'),
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
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: primary, borderRadius: getMessageType(messageType)),
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
        padding: EdgeInsets.all(1.0),
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
                    color: Hexcolor('#F29F05'),
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
