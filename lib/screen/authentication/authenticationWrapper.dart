import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/authentication/methods/forgotPasswordForm.dart';
import 'package:wowtalent/screen/authentication/methods/loginForm.dart';
import 'package:wowtalent/screen/authentication/methods/registerForm.dart';

// ignore: must_be_immutable
class Authentication extends StatefulWidget {
  AuthIndex index;
  Authentication(this.index);
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  double _heightOne;
  double _fontOne;
  Size _size;

  void _changeMethod(AuthIndex val) {
    setState(() {
      widget.index = val;
      //widget._isLogin = value;
    });
  }

  topText() {
    if (widget.index == AuthIndex.LOGIN) {
      return "LOGIN";
    } else if (widget.index == AuthIndex.REGISTER) {
      return "REGISTER";
    } else if (widget.index == AuthIndex.FORGOT) {
      return "FORGOT PASSWORD";
    }
  }

  greetingText() {
    switch (widget.index) {
      case AuthIndex.LOGIN:
        return "Welcome Back.";
        break;
      case AuthIndex.FORGOT:
        return "We are always there to help";
        break;
      case AuthIndex.REGISTER:
        return "We'll be glad if you join us.";
        break;
    }
  }

  authPage() {
    switch (widget.index) {
      case AuthIndex.LOGIN:
        return LoginForm(
          changeMethod: _changeMethod,
        );
        break;
      case AuthIndex.FORGOT:
        return ForgotPasswordForm(
          changeMethod: _changeMethod,
        );
        break;
      case AuthIndex.REGISTER:
        return RegisterForm(
          changeMethod: _changeMethod,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: _size.width,
            height: _size.height * 0.5,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50))),
            child: Padding(
              padding: EdgeInsets.only(
                top: _heightOne * 50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    topText(),
                    style: TextStyle(
                        color: AppTheme.backgroundColor,
                        fontSize: widget.index == AuthIndex.FORGOT
                            ? _fontOne * 35
                            : _fontOne * 50,
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    greetingText(),
                    style: TextStyle(
                        color: AppTheme.backgroundColor,
                        fontSize: _fontOne * 20,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(
                top: _size.height * 0.3,
              ),
              height: _size.height * 0.7,
              width: _size.width * 0.9,
              decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(0.4),
                      offset: Offset(0.0, -10.0), //(x,y)
                      blurRadius: 15.0,
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              child: Center(
                child: SingleChildScrollView(
                  child: authPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
