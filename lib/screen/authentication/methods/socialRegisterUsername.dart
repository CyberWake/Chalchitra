import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

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
            FormFieldFormatting.formFieldContainer(
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
    return FlatButton(
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
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Something went wrong try again')));
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
          side: BorderSide(color: Color(0xFFFFCF40), width: _widthOne * 5)),
      splashColor: Colors.orange[100],
      padding: EdgeInsets.symmetric(horizontal: _size.width * 0.29),
      child: Text(
        "Register",
        style: TextStyle(
          color: Color(0xFFFFCF40),
        ),
      ),
    );
  }
}
