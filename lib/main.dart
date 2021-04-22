import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Chalchitra/imports.dart';
//adding this code here

SharedPreferences prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: AppTheme.primaryColor,
    statusBarBrightness: Brightness.light, // navigation bar color
    statusBarColor: AppTheme.primaryColor,
    // status bar color
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('WowUsers');
  UserAuth _userAuth = UserAuth();

  isUserReal() async {
    if (_userAuth.user != null) {
      DocumentSnapshot userRecord =
          await _usersCollection.doc(_userAuth.user.uid).get();
      if (!userRecord.exists) {
        _userAuth.signOut();
      }
    }
  }

  @override
  void initState() {
    isUserReal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('${prefs.containsKey('onBoarded')}');
    return ChangeNotifierProvider(
      create: (_) => CurrentUser(),
      child: StreamProvider<User>.value(
        value: UserAuth().account,
        child: Platform.isIOS
            ? CupertinoApp(
                localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                  DefaultMaterialLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate
                ],
                home: SplashScreen(
                  navigateAfterSeconds: prefs.containsKey('onBoarded')
                      ? MainScreenWrapper(
                          index: _userAuth.user != null ? 0 : 1,
                        )
                      : OnBoardScreen1(),
                ),
                debugShowCheckedModeBanner: false,
                title: "WowTalent",
                theme: CupertinoThemeData(
                    primaryColor: AppTheme.primaryColor,
                    barBackgroundColor: AppTheme.primaryColor,
                    scaffoldBackgroundColor: AppTheme.backgroundColor,
                    textTheme: CupertinoTextThemeData(
                      navTitleTextStyle: TextStyle(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.none,
                          fontSize: 20),
                      textStyle: TextStyle(
                          decoration: TextDecoration.none,
                          color: AppTheme.pureWhiteColor),
                      pickerTextStyle: TextStyle(
                          decoration: TextDecoration.none, color: Colors.black),
                      dateTimePickerTextStyle: TextStyle(
                          decoration: TextDecoration.none, color: Colors.black),
                      navActionTextStyle: TextStyle(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.none),
                      actionTextStyle: TextStyle(color: AppTheme.primaryColor),
                    )),
              )
            : MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'WowTalent',
                theme: ThemeData(
                  backgroundColor: Color(0xFFEBEBEB),
                  primaryColor: Color(0xFF253A52),
                ),
                home: SplashScreen(
                  navigateAfterSeconds: prefs.containsKey('onBoarded')
                      ? MainScreenWrapper(
                          index: _userAuth.user != null ? 1 : 0, //changed
                        )
                      : OnBoardScreen1(),
                ),
              ),
      ),
    );
  }
}
