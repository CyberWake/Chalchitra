import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/messages/messagesChatScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.primaryColorDark,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.backgroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _userAuth.user.uid != widget.uid
              ? IconButton(
                  icon: Icon(
                    Icons.message,
                    color: AppTheme.backgroundColor,
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                                targetUID: widget.uid,
                              ))),
                )
              : Container(),
        ],
      ),
      body: ProfilePage(
        uid: widget.uid,
        isFromSearch: true,
      ),
    );
  }
}
