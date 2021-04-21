import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/mainScreens/activitySection/messages/chatScreen.dart';
import 'package:wowtalent/screen/mainScreens/common/formatTimeStamp.dart';
import 'package:wowtalent/widgets/loadingTiles.dart';

class MessageScreen extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;

    return Container(
      child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
          ),
          child: getBody()),
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
                  ),
                );
              });
        } else {
          if (snapshot.data.docs.length == null) {
            return Center(
              child: Text(
                "No chats found",
                style: TextStyle(
                  color: AppTheme.secondaryColor,
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
            return ListView.separated(
              separatorBuilder: (_, __) => Divider(
                indent: 80,
                color: AppTheme.grey,
              ),
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
                          return ChatScreen(
                            targetUID: values[index],
                          );
                          // return ChatDetailPage(
                          //   targetUID: values[index],
                          // );
                        },
                        closedBuilder:
                            (BuildContext context, void Function() action) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            margin: EdgeInsets.symmetric(vertical: 2),
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
                                                    color:
                                                        AppTheme.pureWhiteColor,
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
                                                    color:
                                                        AppTheme.pureWhiteColor,
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
