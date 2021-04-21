import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'dart:io';

import 'package:wowtalent/screen/ios_Screens/endDrawer/privacyIOS.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';

class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey =
      GlobalKey<ScaffoldState>();
  UserDataModel user;
  UserAuth _userAuth = UserAuth();
  UserInfoStore _userInfoStore = UserInfoStore();
  DocumentSnapshot _currentUserInfo;
  bool isPrivate;

  setup() async {
    _currentUserInfo =
        await _userInfoStore.getUserInfo(uid: _userAuth.user.uid);
    user = UserDataModel.fromDocument(_currentUserInfo);
    isPrivate = user.private;
    print(isPrivate);
    setState(() {});
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  changePrivacy(bool value) async {
    print("user privacy current " + user.private.toString());
    user.private = value;
    bool updated =
        await _userInfoStore.updatePrivacy(uid: user.id, privacy: user.private);
    setState(() {});
    if (updated) {
      Platform.isIOS
          ? cupertinoSnackbar(context, "Privacy Updated")
          : _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Privacy Updated')));
      print("user privacy updated " + user.private.toString());
    } else {
      Platform.isIOS
          ? cupertinoSnackbar(context, "Something went wrong try again")
          : _scaffoldGlobalKey.currentState.showSnackBar(
              SnackBar(content: Text('Something went wrong try again')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? PrivacyIOS(
            privacyBody: privacyBody(),
          )
        : Scaffold(
            key: _scaffoldGlobalKey,
            backgroundColor: AppTheme.primaryColor,
            appBar: AppBar(
              backgroundColor: AppTheme.primaryColor,
              centerTitle: true,
              title: Text('Privacy'),
            ),
            body: privacyBody());
  }

  Widget privacyBody() {
    return ListView(
      padding: EdgeInsets.only(top: 20),
      children: [
        Material(
          color: AppTheme.primaryColor,
          child: ListTile(
            onTap: () {
              setState(() {
                isPrivate = !isPrivate;
              });
              changePrivacy(isPrivate);
            },
            leading: Icon(Icons.security, color: AppTheme.secondaryColor),
            title: Text('Change account private',
                style: TextStyle(
                    color: AppTheme.pureWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            subtitle: Text('Enabling this will make your account private',
                style: TextStyle(color: AppTheme.pureWhiteColor)),
            trailing: Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: AdvancedSwitch(
                activeColor: AppTheme.secondaryColor,
                inactiveColor: AppTheme.pureWhiteColor,
                activeChild: Text('Private',
                    style: TextStyle(
                        color: AppTheme.pureWhiteColor,
                        fontWeight: FontWeight.bold)),
                inactiveChild: Text('Public',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold)),
                width: 80.0,
                value: user == null ? false : user.private,
                onChanged: (bool value) async {
                  changePrivacy(value);
                },
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
