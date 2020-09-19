import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/auth/auth_api.dart';
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
  UserAuth _userAuth = UserAuth();
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: UserAuth().account,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WowTalent',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: SplashScreen(
            seconds: 3,
            navigateAfterSeconds: prefs.containsKey('onBoarded') ?
            MainScreenWrapper(
              index: _userAuth.user != null ? 0 : 1,
            ) : OnBoardScreen1(),
            image: Image.asset('assets/images/splash.png'),
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: TextStyle(),
            photoSize: 100.0,
            onClick: ()=>print("Wow Talent"),
            loaderColor: Colors.orange,
        )
      ),
    );
  }
}
