import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/drafts.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/home/home.dart';
import 'package:wowtalent/screen/mainScreens/messages/messageScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoSelectorScreen.dart';

// ignore: must_be_immutable
class MainScreenWrapper extends StatefulWidget {
  int index;
  MainScreenWrapper({@required this.index});
  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  List<Widget> _screens;
  int _currentIndex = 0;
  double _widthOne;
  double _heightOne;
  double _iconOne;
  Size _size;
  bool _isMessagePage = false;
  Widget _profilePage = Container();
  UserAuth _userAuth = UserAuth();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserDataModel user;
  DocumentSnapshot _currentUserInfo;

  SharedPreferences prefs;

  void setup() async{
    if(_userAuth.user != null) {
      print('running');
      _currentUserInfo = await _userInfoStore.getUserInfo(
          uid: _userAuth.user.uid
      );
      user = UserDataModel.fromDocument(_currentUserInfo);
    }
    prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('onBoarded')){
      prefs.setBool("onBoarded", true);
    }
    setState(() {});
  }


  @override
  void initState(){
    setup();
    super.initState();
    _currentIndex = widget.index;
  }

  _buildConfirmSignOut(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20.0),
      ), //this right here
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.deepOrangeAccent,width: 3)
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0,left: 10),
                child: Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: _size.width * 0.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.deepOrangeAccent,width: 2)
                        ),
                        onPressed: () async{
                          await UserAuth().signOut().then((value){
                            if(value){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Authentication(AuthIndex.LOGIN)
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
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.orangeAccent,
                      ),
                    ),
                    SizedBox(
                      width: _size.width * 0.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.deepOrangeAccent,width: 2)
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
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
      key: _scaffoldGlobalKey,
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
          _currentIndex != 4 ?
          IconButton(
            icon: Icon(
              Icons.search,
              color: _isMessagePage? Colors.black: Colors.orange.shade400,
              size: _iconOne * 30,
            ),
            onPressed: (){
              if (_userAuth.user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SearchUser()
                  )
                );
              }else{
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => Authentication(AuthIndex.REGISTER)
                    )
                );
              }
            },
          ):IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.orange.shade400,
              size: _iconOne * 25,
            ),
            onPressed: () => _scaffoldGlobalKey.currentState.openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ) ,
          SizedBox(width: _widthOne * 100,)
        ],
      ),
      endDrawer: SafeArea(
        child: Container(
          width: _size.width * 0.5,
          child: Drawer(
            child: Container(
              color: Colors.black87,
              child: Column(
                children: [
                  ListTile(
                    title: Center(
                      child: Text(user == null?" ":user.username,
                          style:TextStyle(color: Colors.white)),
                    ),
                  ),
                  Divider(color: Colors.white,thickness: 0.5,),
                  ListTile(
                    leading: Icon(Icons.drafts,color: Colors.white),
                    title: Text("Drafted Post",
                        style:TextStyle(color: Colors.white)
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          CupertinoPageRoute(
                              builder: (BuildContext context)=> Drafts()
                          )
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.security,color: Colors.white),
                    title: Text('Privacy',style:TextStyle(color: Colors.white)),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.group_add,color: Colors.white),
                    title: Text('Invite',style:TextStyle(color: Colors.white)),
                    onTap: () async {
                      await FlutterShare.share(
                          title: 'Join WowTalent',
                          text: 'I am Loving the app. I invite you to join me'+
                                ' in the journey to show your talent!!',
                          linkUrl: 'http://www.mediafire.com/folder/gqt2pihrq20h9/Documents',
                          chooserTitle: 'Test'
                      );
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  Divider(color: Colors.white,thickness: 0.5,),
                  ListTile(
                    leading: Icon(Icons.power_settings_new,color: Colors.white),
                    title: Text('Signout',style:TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => _buildConfirmSignOut(context),
                      );
                    },
                  ),
                ],
              ),
            )
          ),
        ),
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
            Navigator.pushReplacement(context, CupertinoPageRoute(builder:
                (context)=>Authentication(AuthIndex.REGISTER)));
          }
          print(index);
          if(index == 4){
            print(index);
            UserAuth().account.listen((user){
              if(user != null){
                _profilePage = ProfilePage(uid: user.uid);
              }
            });
            _isMessagePage = false;
            _currentIndex = index;
          }else if(index == 3){
            _isMessagePage = true;
            _currentIndex = index;
          }else{
            _isMessagePage = false;
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
