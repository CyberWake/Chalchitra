import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/screen/authentication/formFiledFormatting.dart';
import 'package:wowtalent/screen/authentication/validation.dart';

class LoginForm extends StatefulWidget {
  final ValueChanged<bool> changeMethod;
  LoginForm({this.changeMethod});
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = "", _password = "";
  double _widthOne;
  double _heightOne;
  double _fontOne;
  double _iconOne;
  Size _size;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _widthOne * 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            authFormFieldContainer(
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
                onChanged: (val) {
                  _email = val;
                },
                decoration: authFormFieldFormatting(
                    hintText: "Enter Email",
                    fontSize: _fontOne * 15
                ),
                style: TextStyle(
                  fontSize: _fontOne * 15,
                ),
              ),
              leftPadding: _widthOne * 20,
            ),
            SizedBox(height: _heightOne * 10,),
            authFormFieldContainer(
              child: TextFormField(
                obscureText: true,
                validator: validateEmail,
                onChanged: (val) {
                  _password = val;
                },
                decoration: authFormFieldFormatting(
                    hintText: "Enter Password",
                    fontSize: _fontOne * 15
                ),
                style: TextStyle(
                  fontSize: _fontOne * 15,
                ),
              ),
              leftPadding: _widthOne * 20,
            ),
            SizedBox(height: _heightOne * 15,),
            FlatButton(
                onPressed: (){
                  if(_formKey.currentState.validate()){
                    
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.purple.withOpacity(0.75),
                    width: _widthOne * 5
                  )
                ),
                splashColor: Colors.purple[100],
                padding: EdgeInsets.symmetric(
                  horizontal: _size.width * 0.3
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.purple.withOpacity(0.75),
                  ),
                )
            ),
            SizedBox(height: _heightOne * 15,),
            Text(
              "Or Login With",
              style: TextStyle(
                color: Colors.grey,
                fontSize: _fontOne * 15
              ),
            ),
            SizedBox(height: _heightOne * 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){},
                  child: Image.asset(
                    "assets/images/fb.png",
                    scale: _fontOne * 9,
                  ),
                ),
                SizedBox(width: _widthOne * 50,),
                InkWell(
                  onTap: (){},
                  child: Image.asset(
                    "assets/images/google.png",
                    scale: _fontOne * 9,
                  ),
                ),
              ],
            ),
            SizedBox(height: _heightOne * 50,),
            InkWell(
              onTap: (){
                widget.changeMethod(false);
              },
              child: Text(
                "Don't Have an account? \nTap here to register.",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: _fontOne * 15
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: _heightOne * 30,),
          ],
        ),
      ),
    );
  }
}
