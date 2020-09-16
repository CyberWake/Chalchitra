import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/home/home.dart';
import 'package:wowtalent/screen/mainScreens/messages/messageScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoUploaderScreen.dart';

// ignore: must_be_immutable
class MainScreenWrapper extends StatefulWidget {
  int index;
  MainScreenWrapper({@required this.index});
  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  List<Widget> _screens;
  int _currentIndex = 0;
  double _widthOne;
  double _heightOne;
  double _iconOne;
  Size _size;
  bool _isMessagePage = false;
  Widget _profilePage = Container();
  UserAuth _userAuth = UserAuth();
  SharedPreferences prefs;

  void setup() async{
    prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('onBoarded')){
      prefs.setBool("onBoarded", true);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    setup();
  }
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _iconOne = (_size.height * 0.066) / 50;
    _screens = [
      Home(),
      Explore(),
      VideoUploader(),
      Message(),
      _profilePage,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: _isMessagePage ? Colors.orange:Colors.transparent,
        title: Container(
          padding: EdgeInsets.symmetric(
              vertical: 10,
          ),
            height: 55,
            width: _size.width / 2.5,
          child: Image.asset('assets/images/appBarLogo1.png',fit: BoxFit.fitHeight,),
        ),
        actions: [
          _currentIndex != 4 ? IconButton(
            icon: Icon(
              Icons.search,
              color: _isMessagePage? Colors.black: Colors.orange.shade400,
              size: _iconOne * 30,
            ),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SearchUser()
                )
              );
            },
          ) : IconButton(
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.orange.shade400,
              size: _iconOne * 25,
            ),
            onPressed: () async{
              await UserAuth().signOut().then((value){
                if(value){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => Authentication()
                      )
                  );
                }else{
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Something went wrong try again')
                      )
                  );
                }
              });
            },
          ) ,
          SizedBox(width: _widthOne * 100,)
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: _heightOne * 45,
        backgroundColor: Colors.transparent,
        color: Colors.orange.shade400,
        buttonBackgroundColor: Colors.orange.shade400,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 25,
            color: Colors.white,
          ),
          Icon(
            Icons.explore,
            size: 25,
            color: Colors.white,
          ),
          Icon(
            Icons.add,
            size: 25,
            color: Colors.white,
          ),
          Transform.rotate(
            angle: 180 * pi / 100,
            child: Icon(
              Icons.send,
              size: 25,
              color: Colors.white,
            ),
          ),
          Icon(
            Icons.account_circle,
            size: 25,
            color: Colors.white,
          ),
        ],
        onTap: (index) async{
          if(_userAuth.user == null){
            Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=>Authentication()));
          }
          print(index);
          if(index == 4){
            print(index);
            UserAuth().account.listen((user){
              if(user != null){
                _profilePage = ProfilePage(uid: user.uid);
              }
            });
            _currentIndex = index;
          }else if(index == 3){
            _isMessagePage = true;
            _currentIndex = index;
            setState(() {
            });
          }else{
            _currentIndex = index;
            _isMessagePage = false;
          }
          setState(() {});
        },
      ),
      body: Container(
          margin: EdgeInsets.only(
            bottom: 10
          ),
          child: _screens[_currentIndex]
      ),
    );
  }
}
