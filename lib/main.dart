import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/introScreen.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';
import 'package:wowtalent/splashScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

SharedPreferences prefs;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  GlobalKey _cupertino = GlobalKey();
  @override
  Widget build(BuildContext context) {
    UserAuth _userAuth = UserAuth();
    return StreamProvider<User>.value(
      value: UserAuth().account,
      child: Platform.isIOS ? CupertinoApp(
        localizationsDelegates:<LocalizationsDelegate<dynamic>> [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        key: _cupertino,
        home:SplashScreen(
          navigateAfterSeconds: prefs.containsKey('onBoarded')
              ? MainScreenWrapper(index: _userAuth.user != null ? 0 : 1,)
              : OnBoardScreen1(),
        ),
        debugShowCheckedModeBanner: false,
        title: "WowTalent",
        theme: CupertinoThemeData(
          primaryColor: Colors.orange,
          barBackgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          textTheme: CupertinoTextThemeData(
            navTitleTextStyle: TextStyle(color: Colors.orange,decoration: TextDecoration.none,fontSize: 20),
            textStyle: TextStyle(decoration: TextDecoration.none,color: Colors.black),
            pickerTextStyle: TextStyle(decoration: TextDecoration.none,color: Colors.black),
            dateTimePickerTextStyle: TextStyle(decoration: TextDecoration.none,color: Colors.black),
            navActionTextStyle: TextStyle(color: Colors.orange,decoration: TextDecoration.none),
            actionTextStyle: TextStyle(color: Colors.orange),
          )
        ),
      ) : MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WowTalent',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: SplashScreen(
          navigateAfterSeconds: prefs.containsKey('onBoarded')
              ? MainScreenWrapper(index: _userAuth.user != null ? 0 : 1,)
              : OnBoardScreen1(),
        ),
      ),
    );
  }
}
