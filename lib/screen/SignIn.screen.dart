import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';

class SignIn_Screen extends StatefulWidget {
  // SignIn_Screen({Key key}) : super(key: key);

  @override
  _SignIn_ScreenState createState() => _SignIn_ScreenState();
}

class _SignIn_ScreenState extends State<SignIn_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            Container(
              height: 300,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/app.png'),
                      fit: BoxFit.cover)),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: null,
                ),
                Expanded(
                    child: Container(
                  margin: EdgeInsets.only(right: 20, left: 10),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Email'),
                  ),
                ))
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
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
                  ),
                ))
              ]),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                    height: 60,
                    child: RaisedButton(
                      onPressed: () {},
                      color: Color(0xFF00a79B),
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'SignUp');
              },
              child: Center(
                  child: RichText(
                text: TextSpan(
                    text: 'Don\'t have an account?',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: 'SIGN UP',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ))
                    ]),
              )),
            )
          ],
        ));
  }
}
