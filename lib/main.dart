import 'package:flutter/material.dart';
import 'package:wowtalent/screen/Home.screen.dart';
import 'package:wowtalent/screen/SignIn.screen.dart';
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
          return notifier.user != null ? HomeScreen() : Login();
        },
      ),
      // initialRoute: 'SignIn',
      routes: <String, WidgetBuilder>{
        // '/': (_) => new Login(), // Login Page
        '/home': (_) => new HomeScreen(), // Home Page
        // '/signUp': (_) => new SignUp(), // The SignUp page
        // '/forgotPassword': (_) => new ForgotPwd(), // Forgot Password Page
      },
    );
  }
}
