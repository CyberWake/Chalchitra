import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/home/home.dart';

class MainScreenWrapper extends StatefulWidget {
  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  List<Widget> _screens;
  int _currentIndex = 0;
  double _widthOne;
  double _heightOne;
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
    _screens = [
      Home(),
      Explore(),
      Container(),
      Container(),
      Container(),
    ];
    if(_screens == null){

    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.all(_iconOne * 10),
          child: Text(
            "WowTalent",
            style: TextStyle(
              color: Colors.purple.shade400
            ),
          ),
        ),
        actions: [
          Icon(
            Icons.search,
            color: Colors.purple.shade400,
            size: _iconOne * 30,
          ),
          SizedBox(width: _widthOne * 100,)
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: _heightOne * 45,
        backgroundColor: Colors.white,
        color: Colors.purple.shade400,
        buttonBackgroundColor: Colors.purple.shade400,
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
          Icon(
            Icons.chat,
            size: 25,
            color: Colors.white,
          ),
          Icon(
            Icons.account_circle,
            size: 25,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _screens[_currentIndex],
    );
  }
}
