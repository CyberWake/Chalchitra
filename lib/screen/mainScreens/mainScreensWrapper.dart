import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/dynamicLinkService.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/privacyPage.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/home/home.dart';
import 'package:wowtalent/screen/mainScreens/messages/messageScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_upload_screens/videoSelectorScreen.dart';

import '../../model/theme.dart';
import '../../model/theme.dart';
import '../../model/theme.dart';
import '../../model/theme.dart';
import '../../model/theme.dart';
import 'endDrawerScreens/drafts.dart';

// ignore: must_be_immutable
class MainScreenWrapper extends StatefulWidget {
  int index;
  MainScreenWrapper({@required this.index});
  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _cupertinoScaffoldGlobalKey =
      GlobalKey<ScaffoldState>();
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
  DynamicLinkService links = DynamicLinkService();
  Timer _timerLink;

  SharedPreferences prefs;

  void setup() async {
    if (_userAuth.user != null) {
      print(_userAuth.user.uid);
      _currentUserInfo =
          await _userInfoStore.getUserInfo(uid: _userAuth.user.uid);
      user = UserDataModel.fromDocument(_currentUserInfo);
    }
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('onBoarded')) {
      prefs.setBool("onBoarded", true);
    }
    setState(() {});
  }

  _retrieveDynamicLink() async {
    await links.handleDynamicLinks(context, false);
    if (!links.isFromLink) {
      setup();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("running did change");
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(const Duration(milliseconds: 850), () {
        _retrieveDynamicLink();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _retrieveDynamicLink();
    super.initState();
    _currentIndex = widget.index;
  }

  _buildConfirmSignOut(context) {
    return Platform.isIOS ? CupertinoAlertDialog(
      title: Text("Logout"),
      content: Padding(
        padding: EdgeInsets.only(top: 20.0, left: 10),
        child: Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 18),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: CupertinoButton(
            child: Text(
              "Yes",
            ),
            onPressed: () async {
              await UserAuth().signOut().then((value) {
                if (value) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (_) =>
                              Authentication(AuthIndex.LOGIN)));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content:
                      Text('Something went wrong try again')));
                }
              });
            },
          ),
        ),
        CupertinoDialogAction(
          child: CupertinoButton(
            child: Text(
              "No",

            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
      ],
      insetAnimationCurve: Curves.easeInExpo,
      insetAnimationDuration: Duration(milliseconds: 1000),
    ) : Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ), //this right here
      child: Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppTheme.primaryColor, width: 3)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0, left: 10),
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
                            side: BorderSide(
                                color: AppTheme.primaryColor, width: 2)),
                        onPressed: () async {
                          await UserAuth().signOut().then((value) {
                            if (value) {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) =>
                                          Authentication(AuthIndex.LOGIN)));
                            } else {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text('Something went wrong try again')));
                            }
                          });
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: AppTheme.pureWhiteColor),
                        ),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(
                      width: _size.width * 0.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: AppTheme.primaryColor, width: 2)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No",
                          style: TextStyle(color: AppTheme.pureWhiteColor),
                        ),
                        color: AppTheme.primaryColor,
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
    _heightOne = !Platform.isIOS
        ? (_size.height * 0.007) / 5
        : (_size.height * 0.009) / 5;
    _iconOne = (_size.height * 0.066) / 50;
    _screens = [
      Home(),
      Explore(),
      VideoUploader(),
      Message(),
      _profilePage,
    ];

    return Platform.isIOS ? mainScreenWrapperiOS():  Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppTheme.primaryColor,
        title: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          height: 55,
          width: _size.width / 2.5,
          child: Image.asset(
            'assets/images/appBarLogo1.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        actions: [
          _currentIndex != 4
              ? IconButton(
                  icon: Icon(
                    Icons.search,
                    color: AppTheme.backgroundColor,
                    size: _iconOne * 30,
                  ),
                  onPressed: () {
                    if (_userAuth.user != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SearchUser()));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (_) =>
                                  Authentication(AuthIndex.REGISTER)));
                    }
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: AppTheme.elevationColor,
                    size: _iconOne * 25,
                  ),
                  onPressed: () =>
                      _scaffoldGlobalKey.currentState.openEndDrawer(),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
          SizedBox(
            width: _widthOne * 100,
          )
        ],
      ),
      endDrawer: Container(
        width: _size.width * 0.5,
        child: Drawer(
            child: Container(
          color: AppTheme.backgroundColor,
          child: Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    user == null ? " " : user.username,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
              ListTile(
                leading: Icon(Icons.drafts, color: Colors.white),
                title:
                    Text("Drafted Post", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => Drafts()));
                },
              ),
              ListTile(
                leading: Icon(Icons.security, color: Colors.white),
                title: Text('Privacy', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => PrivacyPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.group_add, color: Colors.white),
                title: Text('Invite', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await FlutterShare.share(
                      title: 'Join WowTalent',
                      text: 'I am Loving the app. I invite you to join me' +
                          ' in the journey to show your talent!!',
                      linkUrl:
                          'http://www.mediafire.com/folder/gqt2pihrq20h9/Documents',
                      chooserTitle: 'Invite');
                },
              ),
              Spacer(),
              Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
              ListTile(
                leading: Icon(Icons.power_settings_new, color: Colors.white),
                title: Text('Signout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildConfirmSignOut(context),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: _heightOne * 10),
              )
            ],
          ),
        )),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: _heightOne * 45,
        backgroundColor: Colors.transparent,
        color: AppTheme.primaryColor,
        buttonBackgroundColor: AppTheme.primaryColor,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 25,
            color: AppTheme.backgroundColor,
          ),
          Icon(
            Icons.explore,
            size: 25,
            color: AppTheme.backgroundColor,
          ),
          Icon(
            Icons.add,
            size: 25,
            color: AppTheme.backgroundColor,
          ),
          Transform.rotate(
            angle: 180 * pi / 100,
            child: Icon(
              Icons.send,
              size: 25,
              color: AppTheme.backgroundColor,
            ),
          ),
          Icon(
            Icons.account_circle,
            size: 25,
            color: AppTheme.backgroundColor,
          ),
        ],
        onTap: (index) async {
          if (_userAuth.user == null) {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (context) => Authentication(AuthIndex.REGISTER)));
          }
          print(index);
          if (index == 4) {
            print(index);
            UserAuth().account.listen((user) {
              if (user != null) {
                _profilePage = ProfilePage(uid: user.uid);
              }
            });
            _isMessagePage = false;
            _currentIndex = index;
          } else if (index == 3) {
            _isMessagePage = true;
            _currentIndex = index;
          } else {
            _isMessagePage = false;
            _currentIndex = index;
          }
          setState(() {});
        },
      ),
      body: Container(
          margin: EdgeInsets.only(bottom: 10), child: _screens[_currentIndex]),
    );
  }

  Widget mainScreenWrapperiOS(){
    return CupertinoPageScaffold(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        key: _cupertinoScaffoldGlobalKey,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: AppTheme.primaryColor,
          title: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            height: 55,
            width: _size.width / 2.5,
            child: Image.asset(
              'assets/images/appBarLogo1.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          actions: [
            _currentIndex != 4
                ? IconButton(
              icon: Icon(
                Icons.search,
                color: AppTheme.backgroundColor,
                size: _iconOne * 30,
              ),
              onPressed: () {
                if (_userAuth.user != null) {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => SearchUser()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (_) =>
                              Authentication(AuthIndex.REGISTER)));
                }
              },
            )
                : IconButton(
              icon: Icon(
                 CupertinoIcons.ellipsis,
                color: AppTheme.elevationColor,
                size: _iconOne * 25,
              ),
              onPressed: () =>
                  _cupertinoScaffoldGlobalKey.currentState.openEndDrawer(),
              tooltip:
              MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
            SizedBox(
              width: _widthOne * 100,
            )
          ],
        ),
        endDrawer: Container(
          width: _size.width * 0.5,
          child: Drawer(
              child: Container(
                color: AppTheme.backgroundColor,
                child: Column(
                  children: [
                    DrawerHeader(
                      child: Center(
                        child: Text(
                          user == null ? " " : user.username,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 0.5,
                    ),
                    ListTile(
                      leading: Icon(Icons.drafts, color: Colors.white),
                      title:
                      Text("Drafted Post", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (BuildContext context) => Drafts()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.security, color: Colors.white),
                      title: Text('Privacy', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) => PrivacyPage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.group_add, color: Colors.white),
                      title: Text('Invite', style: TextStyle(color: Colors.white)),
                      onTap: () async {
                        Navigator.pop(context);
                        await FlutterShare.share(
                            title: 'Join WowTalent',
                            text: 'I am Loving the app. I invite you to join me' +
                                ' in the journey to show your talent!!',
                            linkUrl:
                            'http://www.mediafire.com/folder/gqt2pihrq20h9/Documents',
                            chooserTitle: 'Invite');
                      },
                    ),
                    Spacer(),
                    Divider(
                      color: Colors.white,
                      thickness: 0.5,
                    ),
                    ListTile(
                      leading: Icon(Icons.power_settings_new, color: Colors.white),
                      title: Text('Signout', style: TextStyle(color: Colors.white)),
                      onTap:() {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildConfirmSignOut(context),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: _heightOne * 10),
                    )
                  ],
                ),
              )),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          height: _heightOne * 45,
          backgroundColor:Colors.transparent,
          color: AppTheme.primaryColor,
          buttonBackgroundColor: AppTheme.primaryColor,
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
          onTap: (index) async {
            if (_userAuth.user == null) {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => Authentication(AuthIndex.REGISTER)));
            }
            print(index);
            if (index == 4) {
              print(index);
              UserAuth().account.listen((user) {
                if (user != null) {
                  _profilePage = ProfilePage(uid: user.uid);
                }
              });
              _isMessagePage = false;
              _currentIndex = index;
            } else if (index == 3) {
              _isMessagePage = true;
              _currentIndex = index;
            } else {
              _isMessagePage = false;
              _currentIndex = index;
            }
            setState(() {});
          },
        ),
        body: Container(
          margin: EdgeInsets.only(bottom: 10),
             child: _screens[_currentIndex]),
      ),
    );
  }
}
