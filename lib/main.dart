import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            seconds: 8,
            navigateAfterSeconds: Authentication(),
            /*title: Text('Welcome To the World of Talent',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
              ),),*/
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
