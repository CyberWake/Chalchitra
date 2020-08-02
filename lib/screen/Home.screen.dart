import 'package:flutter/material.dart';

class Home_Screen extends StatefulWidget {
  //Home_Screen({Key key}) : super(key: key);

  @override
  _Home_ScreenState createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/sign.png'),
                  fit: BoxFit.cover))),
    ));
  }
}
