import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
      body: Column(
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
                SizedBox(width: _widthOne * 50,),
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.orange,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: Icon(
                    Icons.message,
                    color: Colors.orange,
                  ),
                  onPressed: (){},
                ),
                SizedBox(width: _widthOne * 50,)
              ],
            ),
          ),
          ProfilePage(uid: widget.uid),
        ],
      ),
    );
  }
}
