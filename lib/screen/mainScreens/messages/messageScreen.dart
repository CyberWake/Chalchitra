import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          color: Colors.purple,
          child: Column(children: <Widget>[
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
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontOne * 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: _widthOne * 100,)
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)
              ),
              child: TextFormField(
                decoration: authInputFormatting.copyWith(
                  hintText: "Search Conversations"
                ),
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
                child: Column(
                  children: List.generate(userMessages.length, (index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ChatDetailPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20, left: 10),
                        child: Row(children: <Widget>[
                          Container(
                              width: 75,
                              height: 75,
                              child: Stack(children: <Widget>[
                                userMessages[index]['story']
                                    ? Container(
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
                                                          userMessages[index]
                                                              ['img']
                                                      ),
                                                      fit: BoxFit.cover)
                                              )
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    userMessages[index]['img']
                                                ),
                                                fit: BoxFit.cover)
                                        ),
                                      )
                              ])),
                          SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      userMessages[index]['name'],
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
                                        userMessages[index]['message'],
                                        style: TextStyle(
                                            fontSize: _fontOne * 13,
                                            color: Colors.black.withOpacity(0.6)
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ]
                              ),
                              SizedBox(width: _widthOne * 100,),
                              Text(
                                userMessages[index]['created_at'],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: _fontOne * 12
                                ),
                              ),
                              SizedBox(width: _widthOne * 20,)
                            ],
                          )
                        ]),
                      ),
                    );
                  }),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
