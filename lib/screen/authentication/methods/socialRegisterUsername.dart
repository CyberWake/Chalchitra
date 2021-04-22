import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';
import 'dart:io';

class SocialRegisterUsername extends StatefulWidget {
  @override
  _SocialRegisterUsernameState createState() => _SocialRegisterUsernameState();
}

class _SocialRegisterUsernameState extends State<SocialRegisterUsername> {
  final _formKey = GlobalKey<FormState>();
  final ref = FirebaseFirestore.instance.collection('WowUsers');
  UserDataModel _userDataModel = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose A Username",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: _fontOne * 20),
            ),
            SizedBox(
              height: _heightOne * 40,
            ),
            Platform.isIOS
                ? CupertinoTextField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      _userDataModel.username = val;
                      if (_submitted) {
                        _formKey.currentState.validate();
                      }
                    },
                    style: TextStyle(color: AppTheme.backgroundColor),
                    placeholderStyle: TextStyle(
                        color: AppTheme.backgroundColor,
                        fontSize: _fontOne * 15),
                    placeholder: "Enter Username",
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.75)),
                        borderRadius: BorderRadius.circular(15.0)),
                  )
                : FormFieldFormatting.formFieldContainer(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          val.isEmpty ? "Username Can't be Empty" : null,
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
                  ),
            SizedBox(
              height: _heightOne * 15,
            ),
            _registerButton(),
            SizedBox(
              height: _heightOne * 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return Platform.isIOS
        ? CupertinoButton(
            color: AppTheme.primaryColor,
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                bool validUsername = await _userInfoStore.isUsernameNew(
                    username: _userDataModel.username);
                if (!validUsername) {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (_) {
                        return CupertinoActionSheet(
                          title: Text("Username already exists"),
                          cancelButton: CupertinoButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      });
                } else {
                  await _userInfoStore
                      .createUserRecord(username: _userDataModel.username)
                      .then((result) {
                    if (!result) {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (_) {
                            return CupertinoActionSheet(
                              title:
                                  Text("Something went wrong try again later"),
                              cancelButton: CupertinoButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          });
                    } else {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => MainScreenWrapper(
                                    index: 0,
                                  )));
                    }
                  });
                }
              } else {
                setState(() {
                  _submitted = true;
                });
              }
            },
            padding: EdgeInsets.symmetric(horizontal: _size.width * 0.29),
            child: Text(
              "Register",
              style: TextStyle(
                color: Colors.orange.withOpacity(0.75),
              ),
            ),
          )
        : FlatButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                bool validUsername = await _userInfoStore.isUsernameNew(
                    username: _userDataModel.username);
                if (!validUsername) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Username already exists')));
                } else {
                  await _userInfoStore
                      .createUserRecord(username: _userDataModel.username)
                      .then((result) {
                    if (!result) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Something went wrong try again')));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MainScreenWrapper(
                                    index: 0,
                                  )));
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
                side: BorderSide(
                    color: AppTheme.primaryColor, width: _widthOne * 5)),
            splashColor: Colors.orange[100],
            color: AppTheme.secondaryColor,
            padding: EdgeInsets.symmetric(horizontal: _size.width * 0.29),
            child: Text(
              "Register",
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          );
  }
}
