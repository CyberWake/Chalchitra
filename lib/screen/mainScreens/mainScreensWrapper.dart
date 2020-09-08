import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/home/home.dart';
import 'package:wowtalent/screen/mainScreens/messages/messageScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoUploaderScreen.dart';

class MainScreenWrapper extends StatefulWidget {
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
  Widget _profilePage = Container();


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
      Container(),
      _profilePage,
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
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.purple.shade400,
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
        onTap: (index) async{
          if(index == 4){
            _profilePage = ProfilePage(uid: UserAuth().user.uid);
            _currentIndex = index;
          }else if(index == 3){
            await Navigator.push(context, MaterialPageRoute(
              builder: (context) => Message()
            ));
          }else{
            _currentIndex = index;
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
