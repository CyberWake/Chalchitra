import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';
import 'dart:io';

class ForgotPasswordForm extends StatefulWidget {
  final ValueChanged<AuthIndex> changeMethod;
  ForgotPasswordForm({this.changeMethod});
  @override
  ForgotPasswordFormState createState() => ForgotPasswordFormState();
}

class ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  UserDataModel _userDataModel = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _user = UserAuth();
  double _widthOne;
  double _heightOne;
  double _fontOne;
  Size _size;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _widthOne * 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: _heightOne * 1,
            ),
            Platform.isIOS
                ? Material(
                    child: _emailField(),
                  )
                : _emailField(),
            SizedBox(
              height: _heightOne * 15,
            ),
            _submitButton(),
            SizedBox(
              height: _heightOne * 15,
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
            SizedBox(
              height: _heightOne * 48,
            ),
          ],
        ),
      ),
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

  showAlertDialog(BuildContext context, String message) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    CupertinoAlertDialog ios_alert = CupertinoAlertDialog(
      title: Text("Message"),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: CupertinoButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: Text("Message"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    Platform.isIOS
        ? showCupertinoDialog(
            context: context,
            builder: (context) {
              return ios_alert;
            })
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
  }

  Widget _submitButton() {
    return Platform.isIOS
        ? CupertinoButton(
            color: AppTheme.primaryColor,
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                bool validEmail = await _userInfoStore.emailExists(
                    email: _userDataModel.email);
                print(validEmail);
                if (validEmail) {
                  final result =
                      await _user.resetPassword(_userDataModel.email);
                  showAlertDialog(
                    context,
                    result,
                  );
                } else {
                  showAlertDialog(context, "Email does not exist!");
                }
              } else {
                setState(() {
                  _submitted = true;
                });
              }
            },
            padding: EdgeInsets.symmetric(horizontal: _size.width * 0.29),
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.orange.withOpacity(0.75),
              ),
            ))
        : FlatButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                bool validEmail = await _userInfoStore.emailExists(
                    email: _userDataModel.email);
                if (validEmail) {
                  final result =
                      await _user.resetPassword(_userDataModel.email);
                  showAlertDialog(
                    context,
                    result,
                  );
                } else {
                  showAlertDialog(context, "Email does not exist!");
                }
              } else {
                setState(() {
                  _submitted = true;
                });
              }
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(
                    color: AppTheme.primaryColor, width: _widthOne * 5)),
            splashColor: Colors.orange[100],
            color: AppTheme.secondaryColor,
            padding: EdgeInsets.symmetric(horizontal: _size.width * 0.277),
            child: Text(
              "Submit",
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ));
  }
}
