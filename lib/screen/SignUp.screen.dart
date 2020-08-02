import 'package:flutter/material.dart';

class SignUp_Screen extends StatefulWidget {
  // SignUp_Screen({Key key}) : super(key: key);

  @override
  _SignUp_ScreenState createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            BackButton_Widget(),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: null,
                ),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(right: 20, left: 10),
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Username'),
                        )))
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.mail),
                  onPressed: null,
                ),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(right: 20, left: 10),
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Email'),
                        )))
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.lock),
                  onPressed: null,
                ),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(right: 20, left: 10),
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Password'),
                        )))
              ]),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: <Widget>[
                Radio(value: null, groupValue: null, onChanged: null),
                RichText(
                  text: TextSpan(
                      text: 'I have accepted the',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold))
                      ]),
                )
              ]),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                      height: 60,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'Home');
                        },
                        color: Color(0xFF00a79B),
                        child: Text('SIGN UP',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      )),
                ))
          ],
        ));
  }
}

class BackButton_Widget extends StatelessWidget {
  const BackButton_Widget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/app.png'), fit: BoxFit.cover)),
      child: Positioned(
          child: Stack(
        children: <Widget>[
          Positioned(
              top: 20,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Back',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              )),
          Positioned(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Create New Account',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ))
        ],
      )),
    );
  }
}
