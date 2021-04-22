import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Chalchitra/imports.dart';

class ChatScreen extends StatefulWidget {
  String targetUID;
  ChatScreen({this.targetUID});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  double _heightOne;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  UserDataModel _userDataModel = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  bool _loading = true;
  final TextEditingController controller = new TextEditingController();
  bool _checkChatAlreadyAdded = true;
  void setup() async {
    await _userInfoStore
        .getUserInfoStream(uid: widget.targetUID)
        .first
        .then((document) {
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
        color: AppTheme.primaryColor,
        child: Column(
          children: [
            SafeArea(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Platform.isIOS
                        ? CupertinoButton(
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.backgroundColor,
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            })
                        : IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.backgroundColor,
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }),
                    Text(
                      _loading
                          ? " "
                          : _userDataModel.displayName == null
                              ? _userDataModel.username
                              : _userDataModel.displayName,
                      style: TextStyle(
                        color: AppTheme.backgroundColor,
                        fontSize: _fontOne * 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(top: _heightOne * 20),
                    child: _loading
                        ? Center(
                            child: SpinKitCircle(
                              color: AppTheme.primaryColor,
                              size: _fontOne * 60,
                            ),
                          )
                        : messages())),
            sendMessageField()
          ],
        ),
      ),
    );
  }

  Widget sendMessageField() {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      height: 70,
      color: AppTheme.primaryColor,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Material(
              type: MaterialType.button,
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              color: Colors.transparent,
              child: TextFormField(
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Type your message here",

                    // contentPadding: EdgeInsets.all(10),
                    focusColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.white)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.white)),
                    fillColor: AppTheme.pureWhiteColor,
                    filled: true,
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.photo,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {},
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () async {
                        if (text.isEmpty ||
                            text.replaceAll(" ", "").length == 0) {
                          return;
                        }

                        if (_checkChatAlreadyAdded) {
                          await _userInfoStore
                              .checkChatExists(targetUID: widget.targetUID)
                              .then((value) async {
                            print(value);
                            if (value == false) {
                              await _userInfoStore.addChatSender(
                                  targetUID: widget.targetUID);
                              await _userInfoStore.addChatReceiver(
                                  targetUID: widget.targetUID);
                            }
                          });
                          _checkChatAlreadyAdded = false;
                        }

                        await _userInfoStore.sendMessage(
                          targetUID: widget.targetUID,
                          message: text,
                        );
                        controller.clear();
                        text = "";
                      },
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget messages() {
    return StreamBuilder(
      stream: _userInfoStore.getChatDetails(
        targetUID: widget.targetUID,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SpinKitCircle(
              color: AppTheme.backgroundColor,
              size: _fontOne * 60,
            ),
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              var time = DateTime.fromMillisecondsSinceEpoch(
                  snapshot.data.documents[index].data()['timestamp']);
              var hour = time.hour.toString();
              var min = time.minute.toString();
              if (time.minute <= 9) {
                min = "0${min}";
              }
              if (time.hour <= 9) {
                hour = "0${hour}";
              }
              return ChatBubble(
                isMe: snapshot.data.documents[index].data()["reciever"] ==
                    widget.targetUID,
                message: snapshot.data.documents[index].data()['message'],
                timestamp: "${hour}:${min}",
              );
            },
            itemCount: snapshot.data.documents.length,
            reverse: true,
          );
        }
      },
    );
  }
}
