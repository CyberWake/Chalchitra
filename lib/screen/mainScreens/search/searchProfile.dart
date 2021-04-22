import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';
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
  Size _size;
  UserAuth _userAuth = UserAuth();
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    // _fontOne = (_size.height * 0.015) / 11;
    // _iconOne = (_size.height * 0.066) / 50;

    return Platform.isIOS
        ? SearchProfileIOS(
            searchProfileBody: searchProfileBody(),
          )
        : Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: searchProfileBody(),
          );
  }

  Widget searchProfileBody() {
    return Container(
      color: AppTheme.backgroundColor,
      height: double.infinity,
      child: ProfilePageWrapper(
        uid: widget.uid,
        isFromSearch: true,
      ),
      // child: Column(
      //     mainAxisSize: MainAxisSize.max,
      //     children: [
      //       Container(
      //         color: AppTheme.primaryColor,
      //         padding: EdgeInsets.only(
      // top: _heightOne * 35,
      //         ),
      //         child: Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // crossAxisAlignment: CrossAxisAlignment.center,
      // children: <Widget>[
      //   SizedBox(
      //     width: _widthOne * 50,
      //   ),
      //   Platform.isIOS? CupertinoButton(
      //     child: Icon(
      //       Icons.arrow_back_ios,
      //       color: AppTheme.backgroundColor,
      //     ),
      //     onPressed: () => Navigator.pop(context),)
      //     : IconButton(
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       color: AppTheme.backgroundColor,
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   Expanded(child: Container()),
      //   _userAuth.user.uid != widget.uid  ? Platform.isIOS ? CupertinoButton(child: Icon(
      //       Icons.message,
      //       color: AppTheme.backgroundColor,
      //     ), onPressed: () => Navigator.push(
      //         context,
      //         CupertinoPageRoute(
      //             builder: (context) => ChatDetailPage(
      //                   targetUID: widget.uid,
      //                 ))) ) :IconButton(
      //     icon: Icon(
      //       Icons.message,
      //       color: AppTheme.backgroundColor,
      //     ),
      //     onPressed: () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => ChatDetailPage(
      //                   targetUID: widget.uid,
      //                 ))),
      //   ):Container(),
      //   SizedBox(
      //     width: _widthOne * 50,
      //   )
      // ],
      //         ),
      //       ),
      //     ProfilePageWrapper(uid: widget.uid,isFromSearch: true,),
      //   ],
      // ),
    );
  }
}
