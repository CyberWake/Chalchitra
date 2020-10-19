import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/UserInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/helpers/authButtons.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'package:wowtalent/screen/authentication/helpers/validation.dart';
import 'package:wowtalent/screen/authentication/methods/socialRegisterUsername.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class RegisterForm extends StatefulWidget {
  final ValueChanged<AuthIndex> changeMethod;
  RegisterForm({this.changeMethod});
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final ref = FirebaseFirestore.instance.collection('WowUsers');
  UserDataModel _userDataModel = UserDataModel();
  UserAuth _userAuth = UserAuth();
  double _widthOne;
  double _heightOne;
  double _fontOne;
  Size _size;
  bool _registerForm = true;
  bool _hidePassword = true;
  bool _submitted = false;
  UserInfoStore _userInfoStore = UserInfoStore();

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    return _registerForm ? registerForm() : SocialRegisterUsername();
  }

  Widget registerForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _widthOne * 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: _heightOne * 10,
            ),
            _userNameField(),
            SizedBox(
              height: _heightOne * 10,
            ),
            _emailField(),
            SizedBox(
              height: _heightOne * 10,
            ),
            _passwordField(),
            SizedBox(
              height: _heightOne * 10,
            ),
            _confirmPasswordField(),
            SizedBox(
              height: _heightOne * 15,
            ),
            _registerButton(context),
            SizedBox(
              height: _heightOne * 30,
            ),
            Text(
              "Or Register With",
              style: TextStyle(color: Colors.grey, fontSize: _fontOne * 15),
            ),
            SizedBox(
              height: _heightOne * 10,
            ),
            AuthButtons.socialLogin(
                newAccountCallback: () {
                  setState(() {
                    _registerForm = false;
                  });
                },
                context: context,
                size: _size),
            SizedBox(
              height: _heightOne * 20,
            ),
            InkWell(
              onTap: () {
                widget.changeMethod(AuthIndex.LOGIN);
              },
              child: Text(
                "Already Have an account? \nTap here to login.",
                style: TextStyle(color: Colors.black, fontSize: _fontOne * 15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userNameField() {
    return FormFieldFormatting.formFieldContainer(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (val) => val.isEmpty ? "Username Can't be Empty" : null,
        onChanged: (val) {
          _userDataModel.username = val;
          if (_submitted) {
            _formKey.currentState.validate();
          }
        },
        decoration: FormFieldFormatting.formFieldFormatting(
            hintText: "Enter Username", fontSize: _fontOne * 15),
        style: TextStyle(
          fontSize: _fontOne * 15,
        ),
      ),
      leftPadding: _widthOne * 20,
    );
  }

  Widget _emailField() {
    return FormFieldFormatting.formFieldContainer(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: FormValidation.validateEmail,
        onChanged: (val) {
          _userDataModel.email = val;
          if (_submitted) {
            _formKey.currentState.validate();
          }
        },
        decoration: FormFieldFormatting.formFieldFormatting(
            hintText: "Enter Email", fontSize: _fontOne * 15),
        style: TextStyle(
          fontSize: _fontOne * 15,
        ),
      ),
      leftPadding: _widthOne * 20,
    );
  }

  Widget _passwordField() {
    return FormFieldFormatting.formFieldContainer(
      child: TextFormField(
        obscureText: _hidePassword,
        validator: FormValidation.validateRegisterPassword,
        onChanged: (val) {
          _userDataModel.password = val;
        },
        decoration: FormFieldFormatting.formFieldFormatting(
          suffixIcon: IconButton(
            icon: Icon(
              _hidePassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              setState(() {
                _hidePassword = !_hidePassword;
              });
            },
          ),
          hintText: "Enter Password",
          fontSize: _fontOne * 15,
        ),
        style: TextStyle(
          fontSize: _fontOne * 15,
        ),
      ),
      leftPadding: _widthOne * 20,
    );
  }

  Widget _confirmPasswordField() {
    return FormFieldFormatting.formFieldContainer(
      child: TextFormField(
        obscureText: true,
        validator: (val) => val == _userDataModel.password
            ? null
            : "Password in both fields should match",
        onChanged: (val) {},
        decoration: FormFieldFormatting.formFieldFormatting(
            hintText: "Confirm Password", fontSize: _fontOne * 15),
        style: TextStyle(
          fontSize: _fontOne * 15,
        ),
      ),
      leftPadding: _widthOne * 20,
    );
  }

  Widget _registerButton(BuildContext context) {
    return FlatButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            bool validUsername = await _userInfoStore.isUsernameNew(
                username: _userDataModel.username);
            if (!validUsername) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Username already exists')));
            } else {
              await _userAuth
                  .registerUserWithEmail(
                context: context,
                email: _userDataModel.email,
                password: _userDataModel.password,
                username: _userDataModel.username,
              )
                  .then((result) {
                if (result == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Something went wrong try again')));
                } else if (result == "success") {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MainScreenWrapper(
                                index: 0,
                              )));
                } else {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(result)));
                }
              });
            }
          } else {
            setState(() {
              _submitted = true;
            });
          }
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side:
                BorderSide(color: AppTheme.primaryColor, width: _widthOne * 5)),
        splashColor: Colors.orange[100],
        padding: EdgeInsets.symmetric(horizontal: _size.width * 0.29),
        child: Text(
          "Register",
          style: TextStyle(
            color: AppTheme.primaryColor,
          ),
        ));
  }
}
