import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/ios_Screens/search/searchProfileIOS.dart';
import 'package:wowtalent/screen/mainScreens/messages/messagesChatScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';
import 'dart:io';

class SearchProfile extends StatefulWidget {
  final String uid;
  SearchProfile({this.uid});
  @override
  _SearchProfileState createState() => _SearchProfileState();
}

class _SearchProfileState extends State<SearchProfile> {
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
    return Platform.isIOS
        ? SearchProfileIOS(searchProfileBody: searchProfileBody(),)
        : Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: searchProfileBody(),
          );
  }

  Widget searchProfileBody(){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            bottom: _heightOne * 20,
            top: _heightOne * 40,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: _widthOne * 50,
              ),
              Platform.isIOS ? CupertinoButton(
              child: Icon(
    Icons.arrow_back_ios,
    color: AppTheme.primaryColor,
    ),
    onPressed: () => Navigator.pop(context),
    ) : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.pureWhiteColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(child: Container()),
              Platform.isIOS ?  CupertinoButton(
                child: Icon(
                  Icons.message,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ChatDetailPage(
                          targetUID: widget.uid,
                        ))),
              ) :IconButton(
                icon: Icon(
                  Icons.message,
                  color: AppTheme.pureWhiteColor,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                          targetUID: widget.uid,
                        ))),
              ),
              SizedBox(
                width: _widthOne * 50,
              )
            ],
          ),
        ),
        ProfilePage(uid: widget.uid),
      ],
    );
  }
}
