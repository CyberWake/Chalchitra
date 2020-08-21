import 'package:flutter/material.dart';
import 'package:wowtalent/screen/messageScreen.dart';
import 'package:wowtalent/screen/rootScreen.dart';
import 'package:wowtalent/screen/signInScreen.dart';
// import 'package:wowtalent/screen/SignUp.screen.dart';
import 'package:provider/provider.dart';

import 'notifier/auth_notifier.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthNotifier(),
        ),
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WowTalent',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Consumer<AuthNotifier>(
        builder: (context, notifier, child) {
          return notifier.user != null ? RootApp() : Login();
        },
      ),
      // initialRoute: 'SignIn',
      routes: <String, WidgetBuilder>{
        // '/': (_) => new Login(), // Login Page
        '/home': (_) => new RootApp(),
        'message': (_) => new Message(),
        '/Login': (_) => new Login() // Home Page
        // '/signUp': (_) => new SignUp(), // The SignUp page
        // '/forgotPassword': (_) => new ForgotPwd(), // Forgot Password Page
      },
    );
  }
}
