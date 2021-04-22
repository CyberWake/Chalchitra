import 'dart:async';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Chalchitra/imports.dart';

// ignore: must_be_immutable
class MainScreenWrapper extends StatefulWidget {
  final int index;
  final bool isFromLink;
  final List<VideoInfo> videos;
  MainScreenWrapper({@required this.index, this.isFromLink, this.videos});
  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _cupertinoScaffoldGlobalKey =
      GlobalKey<ScaffoldState>();

  final FirebaseMessaging _fcm = FirebaseMessaging();
  TabController _tabController;
  List<Widget> _screens;
  int _currentIndex = 0;
  double _widthOne;
  double _heightOne;
  double _iconOne;
  Size _size;
  bool _isMessagePage = false;
  bool _notLoggedIn = true;
  DateTime currentBackPressTime;
  Widget _profilePage = Container();
  Widget _activitySection = Container();
  UserAuth _userAuth = UserAuth();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserDataModel user;
  DocumentSnapshot _currentUserInfo;
  DynamicLinkService links = DynamicLinkService();
  Timer _timerLink;

  SharedPreferences prefs;

  void setup() async {
    getUser();
    setState(() {});
  }

  void getUser() async {
    if (_userAuth.user != null) {
      _notLoggedIn = false;
      print(_userAuth.user.uid);
      await _userInfoStore.updateToken(context: context);
      _currentUserInfo =
          await _userInfoStore.getUserInfo(uid: _userAuth.user.uid);
      user = UserDataModel.fromDocument(_currentUserInfo);
      Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
      // _profilePage = ProfilePage(
      //   uid: user.id,
      //   isFromSearch: false,
      // );
      _activitySection = ActivityWrapper(
        uid: user.id,
      );
      _profilePage = ProfilePageWrapper(
        uid: user.id,
        isFromSearch: false,
      );
    } else {
      _notLoggedIn = true;
    }
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('onBoarded')) {
      prefs.setBool("onBoarded", true);
    }
    print('prefs onboard: ${prefs.containsKey('onBoarded')}');
  }

  _retrieveDynamicLink() async {
    if (_userAuth.user != null) {
      UserDataModel userData =
          await _userInfoStore.getUserInformation(uid: _userAuth.user.uid);
      Provider.of<CurrentUser>(context, listen: false)
          .updateCurrentUser(userData);
    }
    await links.handleDynamicLinks(context, false);
    if (!links.isFromLink) {
      setup();
    } else {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (BuildContext context) => Player(
                videos: links.videos,
                index: 0,
              )));
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
    super.initState();
    _currentIndex = widget.index;
    _tabController = TabController(length: 5, vsync: this);
    _tabController.index = _currentIndex;
    getUser();
    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 0.0),
            title: Text(message['notification']['title']),
            subtitle: Text(message['notification']['body']),
            onTap: () {
              if (message['type'] == "like") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => ActivityPage(uid: _userAuth.user.uid)));
              } else if (message['type'] == "comment") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => CommentsScreen(
                              videoId: message["videoID"],
                            )));
              } else if (message['type'] == "msg") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => ChatDetailPage(
                              targetUID: message["senderID"],
                            )));
              } else if (message['type'] == "follow") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => SearchProfile(
                              uid: message['followerID'],
                            )));
              }
            },
          )));
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch work");
      if (message['type'] == "like") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ActivityPage(uid: _userAuth.user.uid)));
      } else if (message['type'] == "comment") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => CommentsScreen(
                      videoId: message["videoID"],
                    )));
      } else if (message['type'] == "msg") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ChatDetailPage(
                      targetUID: message["senderID"],
                    )));
      } else if (message['type'] == "follow") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => SearchProfile(
                      uid: message['followerID'],
                    )));
      }
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume");
      if (message['type'] == "like") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ActivityPage(uid: _userAuth.user.uid)));
      } else if (message['type'] == "comment") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => CommentsScreen(
                      videoId: message["videoID"],
                    )));
      } else if (message['type'] == "msg") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ChatDetailPage(
                      targetUID: message["senderID"],
                    )));
      } else if (message['type'] == "follow") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => SearchProfile(
                      uid: message['followerID'],
                    )));
      }
    });
  }

  _buildConfirmSignOut(context) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ), //this right here
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border:
                          Border.all(color: AppTheme.primaryColor, width: 3)),
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
                              BouncingButton(
                                buttonText: "Yes",
                                width: _size.width * 0.3,
                                buttonFunction: () async {
                                  await UserAuth().signOut().then((value) {
                                    if (value) {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (_) => Authentication(
                                                  AuthIndex.LOGIN)));
                                    } else {
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              'Something went wrong try again')));
                                    }
                                  });
                                },
                              ),
                              BouncingButton(
                                buttonText: "No",
                                width: _size.width * 0.3,
                                buttonFunction: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container(
            color: Colors.red,
          );
        });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Double tap to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  changePage(int index) {
    if (_notLoggedIn) {
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => Authentication(AuthIndex.REGISTER)));
    }
    print('current Index: $index');
    if (index == 4) {
      if (_activitySection == Container()) {
        _activitySection = ActivityWrapper(
          uid: user.id,
        );
      }
      if (_profilePage == Container()) {
        _profilePage = ProfilePageWrapper(
          uid: user.id,
          isFromSearch: false,
        );
      }
      _isMessagePage = false;
      _currentIndex = index;
      _tabController.index = _currentIndex;
    } else if (index == 3) {
      _isMessagePage = true;
      _currentIndex = index;
      _tabController.index = _currentIndex;
    } else {
      _isMessagePage = false;
      _currentIndex = index;
      _tabController.index = _currentIndex;
    }
    print('newIndex: $index');
    setState(() {});
  }

  userNotLoggedIn() {
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) =>
                Authentication(AuthIndex.REGISTER)));
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
      HomePageWrapper(),
      ExplorePageWrapper(),
      VideoUploader(),
      _activitySection,
      _profilePage,
    ];

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: wrapperMain(),
          )
        : WillPopScope(onWillPop: onWillPop, child: wrapperMain());
  }

  Widget wrapperMain() {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        // endDrawerEnableOpenDragGesture: true,
        key: _scaffoldGlobalKey,
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          indexController: changePage,
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: _screens,
          controller: _tabController,
        ),
      ),
    );
  }
}
