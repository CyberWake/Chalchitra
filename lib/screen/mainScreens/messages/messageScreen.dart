import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Chalchitra/imports.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({Key key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  double _heightOne;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  UserInfoStore _userInfoStore = UserInfoStore();
  List _usersDetails = [];
  bool _isSearchActive = false;
  String _search = "";

  @override
  void initState() {
    super.initState();
  }

  _updateIsSearch(bool val) {
    setState(() {
      _isSearchActive = val;
      _search = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;

    return Platform.isIOS
        ? MessageScreenIOS(
            msgScreenBody: msgScreenBody(),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: _size.height,
                color: AppTheme.primaryColor,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Spacer(),
                          Text(
                            "Messages",
                            style: TextStyle(
                              color: AppTheme.backgroundColor,
                              fontSize: _fontOne * 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(
                        height: 5,
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
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                onTap: () {
                                  _updateIsSearch(true);
                                },
                                onFieldSubmitted: (val) {
                                  setState(() {
                                    _search = val;
                                  });
                                },
                                decoration: authInputFormatting.copyWith(
                                  hintText: "Search By Username",
                                ),
                              ),
                            ),
                            _isSearchActive
                                ? IconButton(
                                    icon: Icon(
                                      Icons.cancel,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () {
                                      _updateIsSearch(false);
                                    },
                                  )
                                : Container(),
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
                            child: _isSearchActive
                                ? SearchMessage(
                                    userName: _search,
                                  )
                                : getBody()),
                      ),
                    ]),
              ),
            ),
          );
  }

  Widget msgScreenBody() {
    return SingleChildScrollView(
      child: Container(
        height: _size.height,
        color: AppTheme.primaryColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  Text(
                    "Messages",
                    style: TextStyle(
                      color: AppTheme.backgroundColor,
                      fontSize: _fontOne * 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(
                height: 5,
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
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Expanded(
                      child: Platform.isIOS
                          ? CupertinoTextField(
                              style: TextStyle(color: AppTheme.pureBlackColor),
                              placeholderStyle: TextStyle(
                                  color:
                                      AppTheme.pureBlackColor.withOpacity(0.5)),
                              placeholder: "Search by username",
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.transparent)),
                              onTap: () {
                                _updateIsSearch(true);
                              },
                              onSubmitted: (val) {
                                setState(() {
                                  _search = val;
                                });
                              },
                            )
                          : TextFormField(
                              onTap: () {
                                _updateIsSearch(true);
                              },
                              onFieldSubmitted: (val) {
                                setState(() {
                                  _search = val;
                                });
                              },
                              decoration: authInputFormatting.copyWith(
                                hintText: "Search By Username",
                              ),
                            ),
                    ),
                    _isSearchActive
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: () {
                              _updateIsSearch(false);
                            },
                          )
                        : Container(),
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
                    child: _isSearchActive
                        ? SearchMessage(
                            userName: _search,
                          )
                        : getBody()),
              ),
            ]),
      ),
    );
  }

  Widget getBody() {
    return StreamBuilder(
      stream: _userInfoStore.getChats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListView.builder(
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return Shimmer.fromColors(
                  highlightColor: AppTheme.backgroundColor,
                  baseColor: AppTheme.pureWhiteColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(
                          color: AppTheme.primaryColorDark, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              });
        } else {
          if (snapshot.data.docs.length == null) {
            return Center(
              child: Text(
                "No chats found",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: _fontOne * 16,
                ),
              ),
            );
          }
          List keys = [];
          snapshot.data.documents.forEach((doc) {
            keys.add(doc.id);
          });
          List values = [];
          snapshot.data.documents.forEach((doc) {
            values.add(doc.data()["uid"]);
          });
          // List keys = snapshot.data.data().keys.toList();
          // List values = snapshot.data.data().values.toList();
          // print(keys);
          getUsersDetails(values);
          if (keys.isEmpty) {
            return Center(
              child: Text(
                "No chats found",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: _fontOne * 16,
                ),
              ),
            );
          } else if (_usersDetails.length < keys.length) {
            return LoadingCards();
          } else {
            return ListView.builder(
              padding: EdgeInsets.only(left: 15.0, right: 15, bottom: 20),
              itemBuilder: (context, index) {
                if (_usersDetails[index] == null) {
                  return Container();
                } else {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: FittedBox(
                      child: OpenContainer(
                        closedElevation: 0.0,
                        closedColor: Colors.transparent,
                        closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        transitionDuration: Duration(milliseconds: 200),
                        transitionType: ContainerTransitionType.fadeThrough,
                        openBuilder: (BuildContext context,
                            void Function({Object returnValue}) action) {
                          return ChatDetailPage(
                            targetUID: values[index],
                          );
                        },
                        closedBuilder:
                            (BuildContext context, void Function() action) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            margin: EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1.5,
                                              color: AppTheme.primaryColor),
                                          image: DecorationImage(
                                              image: NetworkImage(_usersDetails[
                                                              index]
                                                          .photoUrl ==
                                                      null
                                                  ? "https://via.placeholder.com/150"
                                                  : _usersDetails[index]
                                                      .photoUrl),
                                              fit: BoxFit.cover))),
                                ),
                              ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                _usersDetails[index].username,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: AppTheme
                                                        .primaryColorDark,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              SizedBox(
                                                width: _size.width * 0.45,
                                                child: Text(
                                                  snapshot.hasData
                                                      ? snapshot
                                                          .data.documents[0]
                                                          .data()['message']
                                                      : ".....",
                                                  style: TextStyle(
                                                    fontSize: _fontOne * 13,
                                                    color: AppTheme
                                                        .primaryColorDark,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ]),
                                        SizedBox(
                                          width: _widthOne * 40,
                                        ),
                                        Text(
                                          snapshot.hasData
                                              ? formatDateTime(
                                                  millisecondsSinceEpoch:
                                                      snapshot.data.documents[0]
                                                          .data()['timestamp'])
                                              : ".....",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: _fontOne * 12),
                                        ),
                                        SizedBox(
                                          width: _widthOne * 20,
                                        )
                                      ],
                                    );
                                  })
                            ]),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              itemCount: snapshot.data.documents.length,
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
      if (result != null) {
        _usersDetails.add(UserDataModel.fromDocument(result));
      } else {
        _usersDetails.add(null);
      }
    }
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      setState(() {});
    });
  }
}
