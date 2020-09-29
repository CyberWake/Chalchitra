import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/introScreen.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';
import 'package:wowtalent/splashScreen.dart';

SharedPreferences prefs;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserAuth _userAuth = UserAuth();
    return StreamProvider<User>.value(
      value: UserAuth().account,
      child: MaterialApp(
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
