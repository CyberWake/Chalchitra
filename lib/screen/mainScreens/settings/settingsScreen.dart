import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/drafts.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/helpAndFeedbackPage.dart';
import 'package:wowtalent/screen/mainScreens/endDrawerScreens/privacyPage.dart';
import 'package:wowtalent/widgets/bouncingButton.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notLoggedIn = true;
  UserAuth _userAuth = UserAuth();
  Size _size;

  UserInfoStore _userInfoStore = UserInfoStore();
  UserDataModel user;
  DocumentSnapshot _currentUserInfo;

  void getUser() async {
    if (_userAuth.user != null) {
      _notLoggedIn = false;
      print(_userAuth.user.uid);
      await _userInfoStore.updateToken(context: context);
      _currentUserInfo =
          await _userInfoStore.getUserInfo(uid: _userAuth.user.uid);
      user = UserDataModel.fromDocument(_currentUserInfo);
      Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
    } else {
      _notLoggedIn = true;
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Container(
      color: AppTheme.primaryColor,
      child: Material(
        color: AppTheme.primaryColor,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppTheme.pureWhiteColor,
                        ),
                        onPressed: () => Navigator.pop(context)),
                    Text(
                      "Settings",
                      style: TextStyle(
                          color: AppTheme.pureWhiteColor, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => Drafts()));
              },
              title: Text("Drafts",
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: AppTheme.pureWhiteColor),
            ),
            ListTile(
              title: Text("Change Privacy",
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: AppTheme.pureWhiteColor),
              onTap: () => Navigator.push(
                  context, CupertinoPageRoute(builder: (_) => PrivacyPage())),
            ),
            Divider(indent: 25, endIndent: 25, color: AppTheme.grey),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => FeedBack(
                              user: user,
                            )));
              },
              title: Text("Feedback and Help",
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: AppTheme.pureWhiteColor),
            ),
            Divider(indent: 25, endIndent: 25, color: AppTheme.grey),
            ListTile(
              title: Text('Report a Problem',
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: AppTheme.pureWhiteColor),
            ),
            Divider(indent: 25, endIndent: 25, color: AppTheme.grey),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await FlutterShare.share(
                    title: 'Join WowTalent',
                    text:
                        "I'm loving this app, WowTalent, world's largest talent discovery platform. Download Here:",
                    linkUrl:
                        'http://www.mediafire.com/folder/gqt2pihrq20h9/Documents',
                    chooserTitle: 'Invite');
              },
              title: Text("Invite",
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: AppTheme.pureWhiteColor),
            ),
            Divider(indent: 25, endIndent: 25, color: AppTheme.grey),
            ListTile(
              title: Text("Contact Us",
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: AppTheme.pureWhiteColor),
            ),
            Divider(
              indent: 25,
              endIndent: 25,
              color: AppTheme.grey,
            ),
            ListTile(
              onTap: () {
                _buildConfirmSignOut(context);
              },
              title: Text("Logout",
                  style:
                      TextStyle(color: AppTheme.pureWhiteColor, fontSize: 16)),
              trailing: Icon(Icons.logout, color: AppTheme.pureWhiteColor),
            ),
            Divider(
              indent: 25,
              endIndent: 25,
              color: AppTheme.grey,
            ),
          ],
        ),
      ),
    );
  }
}
