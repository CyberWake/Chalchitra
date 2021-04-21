import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/dynamicLinkService.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/activityPage.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/drafts.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/helpAndFeedbackPage.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/privacyPage.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/screen/mainScreens/home/home.dart';
import 'package:wowtalent/screen/mainScreens/messages/messageScreen.dart';
import 'package:wowtalent/screen/mainScreens/messages/messagesChatScreen.dart';
import 'package:wowtalent/screen/mainScreens/profile/profileScreen.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_upload_screens/videoSelectorScreen.dart';
import 'package:wowtalent/widgets/bouncingButton.dart';

import '../../model/theme.dart';

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

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
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
      _profilePage = ProfilePage(
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
    print('${prefs.containsKey('onBoarded')}');
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 0.0),
            title: Text(message.notification.title),
            subtitle: Text(message.notification.body),
            onTap: () {
              if (message.data['type'] == "like") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => ActivityPage(uid: _userAuth.user.uid)));
              } else if (message.data['type'] == "comment") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => CommentsScreen(
                          videoId: message.data["videoID"],
                        )));
              } else if (message.data['type'] == "msg") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => ChatDetailPage(
                          targetUID: message.data["senderID"],
                        )));
              } else if (message.data['type'] == "follow") {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => SearchProfile(
                          uid: message.data['followerID'],
                        )));
              }
            },
          )));
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async{
      await Firebase.initializeApp();
      if (message.data['type'] == "like") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ActivityPage(uid: _userAuth.user.uid)));
      } else if (message.data['type'] == "comment") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => CommentsScreen(
                  videoId: message.data["videoID"],
                )));
      } else if (message.data['type'] == "msg") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ChatDetailPage(
                  targetUID: message.data["senderID"],
                )));
      } else if (message.data['type'] == "follow") {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => SearchProfile(
                  uid: message.data['followerID'],
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
    print(index);
    if (index == 4) {
      if (_profilePage == Container()) {
        _profilePage = ProfilePage(
          uid: user.id,
          isFromSearch: false,
        );
      }
      print(index);
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
      Home(),
      Explore(),
      VideoUploader(),
      Message(),
      _profilePage,
    ];

    return WillPopScope(onWillPop: onWillPop, child: wrapperMain());
  }

  Widget wrapperMain() {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        endDrawerEnableOpenDragGesture: true,
        key: _scaffoldGlobalKey,
        appBar: AppBar(
          toolbarOpacity: 1.0,
          elevation: 0.0,
          backgroundColor: AppTheme.primaryColor,
          title: Container(
            height: _size.width / 4,
            width: _size.width / 3,
            child: Image.asset(
              'assets/images/appBarLogo1.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          actions: [
            _tabController.index != 4 && _tabController.index != 3
                ? Container(
                    height: _size.width / 4,
                    width: _size.width / 8,
                    child: OpenContainer(
                      closedElevation: 0.0,
                      closedColor: AppTheme.primaryColor,
                      tappable: true,
                      transitionDuration: Duration(milliseconds: 500),
                      openBuilder: (BuildContext context,
                          void Function({Object returnValue}) action) {
                        return !_notLoggedIn
                            ? SearchUser()
                            : Authentication(AuthIndex.REGISTER);
                      },
                      closedBuilder:
                          (BuildContext context, void Function() action) {
                        return Icon(
                          Icons.search,
                          color: AppTheme.backgroundColor,
                          size: _iconOne * 30,
                        );
                      },
                    ),
                  )
                : _tabController.index != 3
                    ? IconButton(
                        icon: StreamBuilder(
                            stream: _userInfoStore.notifCount(
                                uid: _userAuth.user.uid),
                            builder: (_, snap) {
                              if (!snap.hasData) {
                                return Icon(
                                  Icons.menu,
                                  color: AppTheme.backgroundColor,
                                  size: _iconOne * 25,
                                );
                              }
                              if (snap.data.docs.length > 0) {
                                return Stack(
                                  children: [
                                    Icon(
                                      Icons.menu,
                                      color: AppTheme.backgroundColor,
                                      size: _iconOne * 25,
                                    ),
                                    Positioned(
                                      top: 0.0,
                                      left: 13,
                                      child: Icon(
                                        Icons.brightness_1,
                                        color: Colors.redAccent,
                                        size: _iconOne * 12,
                                      ),
                                    )
                                  ],
                                );
                              }
                              return Icon(
                                Icons.menu,
                                color: AppTheme.backgroundColor,
                                size: _iconOne * 25,
                              );
                            }),
                        onPressed: () =>
                            _scaffoldGlobalKey.currentState.openEndDrawer(),
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      )
                    : Container(),
            SizedBox(
              width: _widthOne * 100,
            )
          ],
          automaticallyImplyLeading: false,
        ),
        endDrawer: Container(
          width: _size.width * 0.5,
          child: user != null
              ? Drawer(
                  child: Container(
                  color: AppTheme.primaryColor,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: _size.height * 0.039),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: FittedBox(
                          child: Text(
                            user == null ? " " : user.username,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                        thickness: 0.5,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.drafts,
                          color: AppTheme.pureWhiteColor,
                          semanticLabel: 'Draft',
                          size: 30,
                        ),
                        title: Text("Drafts",
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 18)),
                        onTap: () {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (BuildContext context) => Drafts()));
                        },
                      ),
                      ListTile(
                        leading: StreamBuilder(
                          stream: _userInfoStore.notifCount(
                              uid: _userAuth.user.uid),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return Icon(
                                Icons.notifications,
                                color: AppTheme.pureWhiteColor,
                                semanticLabel: 'Activity',
                                size: 30,
                              );
                            }
                            if (snap.data.docs.length > 0) {
                              return Material(
                                color: Colors.transparent,
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications,
                                      color: AppTheme.pureWhiteColor,
                                      semanticLabel: 'Activity',
                                      size: 30,
                                    ),
                                    Positioned(
                                      top: 0.0,
                                      left: 9.5,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.redAccent),
                                        width: 20.0,
                                        height: 15.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          snap.data.docs.length < 11
                                              ? snap.data.docs.length
                                                  .toString()
                                              : "10+",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: AppTheme.pureWhiteColor,
                                              fontSize: 10.0),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                            return Icon(
                              Icons.notifications,
                              color: AppTheme.pureWhiteColor,
                              semanticLabel: 'Activity',
                              size: 30,
                            );
                          },
                        ),
                        title: Text(
                          "Activity",
                          style: TextStyle(
                              color: AppTheme.pureWhiteColor, fontSize: 18),
                        ),
                        onTap: () {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => ActivityPage(
                                        uid: _userAuth.user.uid,
                                      )));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings,
                            color: AppTheme.pureWhiteColor,
                            semanticLabel: 'Setting',
                            size: 30),
                        title: Text('Settings',
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 18)),
                        onTap: () {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => PrivacyPage()));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.group_add,
                            color: AppTheme.pureWhiteColor,
                            semanticLabel: 'Invite',
                            size: 30),
                        title: Text('Invite',
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 18)),
                        onTap: () async {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          await FlutterShare.share(
                              title: 'Join WowTalent',
                              text:
                                  "I'm loving this app, WowTalent, world's largest talent discovery platform. Download Here:",
                              linkUrl:
                                  'http://www.mediafire.com/folder/gqt2pihrq20h9/Documents',
                              chooserTitle: 'Invite');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.contact_support,
                            color: AppTheme.pureWhiteColor,
                            semanticLabel: 'FeedBack and Help',
                            size: 30),
                        title: Text('FeedBack and Help',
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 18)),
                        onTap: () {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => FeedBack(
                                        user: user,
                                      )));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.contacts,
                            color: AppTheme.pureWhiteColor,
                            semanticLabel: 'Contact Us',
                            size: 30),
                        title: Text('Contact Us',
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 18)),
                        onTap: () {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          /*Navigator.push(
                        context, CupertinoPageRoute(builder: (_) => null));*/
                        },
                      ),
                      Spacer(),
                      ListTile(
                        leading: Icon(Icons.power_settings_new,
                            color: AppTheme.pureWhiteColor,
                            semanticLabel: 'Signout',
                            size: 30),
                        title: Text('Signout',
                            style: TextStyle(
                                color: AppTheme.pureWhiteColor, fontSize: 18)),
                        onTap: () {
                          _notLoggedIn
                              ? userNotLoggedIn()
                              : Navigator.pop(context);
                          _buildConfirmSignOut(context);
                        },
                      ),
                    ],
                  ),
                ))
              : Container(),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          animationDuration: Duration(milliseconds: 400),
          height: Platform.isIOS ? _heightOne * 40 : _heightOne * 55,
          backgroundColor: AppTheme.backgroundColor,
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
            changePage(index);
          },
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
