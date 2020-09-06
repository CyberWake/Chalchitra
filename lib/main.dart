import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/messageScreen.dart';
import 'package:wowtalent/screen/rootScreen.dart';
import 'package:wowtalent/screen/signInScreen.dart';
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
          primarySwatch: Colors.teal,
        ),
        home: UserAuth().user != null ? RootApp() : Authentication(),
        routes: <String, WidgetBuilder>{
          '/home': (_) => new RootApp(),
          'message': (_) => new Message(),
          '/Login': (_) => new Login()
        },
      ),
    );
  }
}
