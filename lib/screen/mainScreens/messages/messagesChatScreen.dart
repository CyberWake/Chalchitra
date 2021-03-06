import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Chalchitra/imports.dart';

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
    return Platform.isIOS
        ? MessageChatScreenIOS(
            msgChatScreenBody: msgChatScreenBody(),
          )
        : Scaffold(
            body: msgChatScreenBody(),
          );
  }

  Widget msgChatScreenBody() {
    return Container(
        padding: EdgeInsets.only(top: _heightOne * 20),
        height: _size.height,
        color: AppTheme.primaryColor,
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
                  SizedBox(
                    width: _widthOne * 50,
                  ),
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
                  Expanded(child: Container()),
                  Text(
                    _loading ? " " : _userDataModel.username,
                    style: TextStyle(
                      color: AppTheme.backgroundColor,
                      fontSize: _fontOne * 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(child: Container()),
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: _iconOne * 25,
                    backgroundImage: CachedNetworkImageProvider(
                        _userDataModel.photoUrl == null
                            ? 'https://via.placeholder.com/150'
                            : _userDataModel.photoUrl),
                  ),
                  SizedBox(
                    width: _widthOne * 100,
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(top: _heightOne * 20),
                    decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                        )),
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
        ));
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
            itemBuilder: (context, index) => MessageBubble(
                isMe: snapshot.data.documents[index].data()["reciever"] ==
                    widget.targetUID,
                message: snapshot.data.documents[index].data()['message'],
                profileImg: _userDataModel.photoUrl == null
                    ? 'https://via.placeholder.com/150'
                    : _userDataModel.photoUrl),
            itemCount: snapshot.data.documents.length,
            reverse: true,
          );
        }
      },
    );
  }

  Widget sendMessageField() {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(bottom: 0),
      height: 70,
      color: AppTheme.backgroundColor,
      child: Row(
        children: <Widget>[
          Platform.isIOS
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: CupertinoButton(
                    child: Icon(Icons.photo,
                        size: 25, color: AppTheme.primaryColor),
                    onPressed: () {},
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.photo),
                  iconSize: 25,
                  color: AppTheme.primaryColor,
                  onPressed: () {},
                ),
          Expanded(
            child: Platform.isIOS
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    height: _heightOne * 30,
                    child: CupertinoTextField(
                      style: TextStyle(
                        color: AppTheme.pureBlackColor,
                      ),
                      controller: controller,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppTheme.pureBlackColor),
                      ),
                      placeholder: "Send a Message",
                      placeholderStyle: TextStyle(
                          color: AppTheme.pureBlackColor.withOpacity(0.5)),
                      onChanged: (val) {
                        text = val;
                      },
                    ),
                  )
                : TextField(
                    controller: controller,
                    onChanged: (val) {
                      text = val;
                    },
                    style: TextStyle(
                      color: AppTheme.pureBlackColor,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Send a message..',
                      hintStyle: TextStyle(
                        color: AppTheme.pureBlackColor.withOpacity(0.5),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
          ),
          Platform.isIOS
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: CupertinoButton(
                    child: Icon(
                      Icons.send,
                      size: 25,
                      color: AppTheme.primaryColor,
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
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.send),
                  iconSize: 25,
                  color: AppTheme.primaryColor,
                  onPressed: () async {
                    if (text.isEmpty || text.replaceAll(" ", "").length == 0) {
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
                ),
        ],
      ),
    );
  }
}
