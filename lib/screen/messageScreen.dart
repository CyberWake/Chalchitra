import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wowtalent/screen/messagesChatScreen.dart';
import 'package:wowtalent/theme/colors.dart';
import 'package:wowtalent/data/user_json.dart';

class Message extends StatefulWidget {
  Message({Key key}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  TextEditingController _searchController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        SafeArea(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 15,
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Text(
                  "Messages",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 15,
                height: 30,
              ),
            ],
          ),
        ),
        SafeArea(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 15,
                height: 30,
              ),
              Container(
                // margin: const EdgeInsets.only(top: 5),
                width: size.width - 30,
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: "Search.....",
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Hexcolor('#F23041'),
                      )),
                  style: TextStyle(fontSize: 18, color: black.withOpacity(.3)),
                  cursorColor: Hexcolor('#F23041').withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Column(
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
                                                  userMessages[index]['img']),
                                              fit: BoxFit.cover))),
                                ),
                              )
                            : Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            userMessages[index]['img']),
                                        fit: BoxFit.cover)),
                              )
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userMessages[index]['name'],
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: size.width - 135,
                          child: Text(
                            userMessages[index]['message'] +
                                " - " +
                                userMessages[index]['created_at'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black.withOpacity(0.8)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ])
                ]),
              ),
            );
          }),
        )
      ]),
    );
  }
}
