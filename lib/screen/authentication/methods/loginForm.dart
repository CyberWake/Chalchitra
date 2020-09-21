import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/helpers/authButtons.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'package:wowtalent/screen/authentication/helpers/validation.dart';
import 'package:wowtalent/screen/authentication/methods/socialRegisterUsername.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class LoginForm extends StatefulWidget {
  final ValueChanged<bool> changeMethod;
  LoginForm({this.changeMethod});
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  UserDataModel _userDataModel = UserDataModel();
  UserAuth _userAuth = UserAuth();
  double _widthOne;
  double _heightOne;
  double _fontOne;
  Size _size;
  bool _loginForm = true;
  String _message = 'Log in/out by pressing the buttons below.';
  bool _submitted = false;

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    return _loginForm ? loginForm() : SocialRegisterUsername();
  }

  Widget loginForm(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _widthOne * 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: _heightOne * 130,),
            _emailField(),
            SizedBox(height: _heightOne * 10,),
            _passwordFiled(),
            SizedBox(height: _heightOne * 15,),
            _loginButton(),
            SizedBox(height: _heightOne * 15,),
            Text(
              "Or Login With",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: _fontOne * 15
              ),
            ),
            SizedBox(height: _heightOne * 10,),
            AuthButtons.socialLogin(
              newAccountCallback: (){
                setState(() {
                  _loginForm = false;
                });
              },
              context: context,
              size: _size
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

  Widget _emailField(){
    return FormFieldFormatting.formFieldContainer(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: FormValidation.validateEmail,
        onChanged: (val) {
          _userDataModel.email = val;
          if(_submitted){
            _formKey.currentState.validate();
          }
        },
        decoration: FormFieldFormatting.formFieldFormatting(
            hintText: "Enter Email",
            fontSize: _fontOne * 15
        ),
        style: TextStyle(
          fontSize: _fontOne * 15,
        ),
      ),
      leftPadding: _widthOne * 20,
    );
  }

  Widget _passwordFiled(){
    return FormFieldFormatting.formFieldContainer(
      child: TextFormField(
        obscureText: true,
        validator: FormValidation.validateLoginPassword,
        onChanged: (val) {
          _userDataModel.password = val;
          if(_submitted){
            _formKey.currentState.validate();
          }
        },
        decoration: FormFieldFormatting.formFieldFormatting(
            hintText: "Enter Password",
            fontSize: _fontOne * 15
        ),
        style: TextStyle(
          fontSize: _fontOne * 15,
        ),
      ),
      leftPadding: _widthOne * 20,
    );
  }

  Widget _loginButton(){
    return FlatButton(
        onPressed: () async{
          if(_formKey.currentState.validate()){
            await _userAuth.signInWithEmailAndPassword(
              email: _userDataModel.email,
              password: _userDataModel.password,
            ).then((result){
              if(result == null){
                Scaffold.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Something went wrong try again')
                    )
                );
              }else if(result == "success"){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreenWrapper(
                          index: 0,
                        )
                    )
                );
              }else{
                Scaffold.of(context).showSnackBar(
                    SnackBar(
                        content: Text(result)
                    )
                );
              }
            });
          }else{
            setState(() {
              _submitted = true;
            });
          }
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
                color: Colors.orange.withOpacity(0.75),
                width: _widthOne * 5
            )
        ),
        splashColor: Colors.orange[100],
        padding: EdgeInsets.symmetric(
            horizontal: _size.width * 0.3
        ),
        child: Text(
          "Login",
          style: TextStyle(
            color: Colors.orange.withOpacity(0.75),
          ),
        )
    );
  }

  /*Widget _socialLogin(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            await _userAuth.signInWithFacebook().then((result){
              if(result == false){
                Scaffold.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Something went wrong try again')
                    )
                );
              }else if(result == true){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreenWrapper(
                          index: 0,
                        )
                    )
                );
              }else{
                setState(() {
                  _loginForm = false;
                });
              }
            });
          },
          child: Image.asset(
            "assets/images/fb.png",
            scale: _fontOne * 9,
          ),
        ),
        SizedBox(width: _widthOne * 50,),
        InkWell(
          onTap: () async{
            await _userAuth.signInWithGoogle().then((result){
              if(result == false){
                Scaffold.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Something went wrong try again')
                    )
                );
              }else if(result == true){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreenWrapper(
                          index: 0,
                        )
                    )
                );
              }else{
                setState(() {
                  _loginForm = false;
                });
              }
            });
          },
          child: Image.asset(
            "assets/images/google.png",
            scale: _fontOne * 9,
          ),
        ),
      ],
    );
  }*/
}
