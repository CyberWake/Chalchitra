import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'package:wowtalent/screen/authentication/helpers/validation.dart';
import 'package:wowtalent/screen/authentication/methods/socialRegisterUsername.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class RegisterForm extends StatefulWidget {
  final ValueChanged<bool> changeMethod;
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

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    return _registerForm ? registerForm() : SocialRegisterUsername();
  }

  Widget registerForm(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _widthOne * 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: _heightOne * 40,),
            authFormFieldContainer(
              child: TextFormField(
                keyboardType: TextInputType.name,
                validator: (val) => val.isEmpty ? "Name Can't be Empty"
                    : null,
                onChanged: (val) {
                  _userDataModel.displayName = val;
                },
                decoration: authFormFieldFormatting(
                    hintText: "Enter your Name",
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
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val.isEmpty ? "Username Can't be Empty"
                    : null,
                onChanged: (val) {

                  _userDataModel.username = val;
                },
                decoration: authFormFieldFormatting(
                    hintText: "Enter Username",
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
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
                onChanged: (val) {
                  _userDataModel.email = val;
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
                validator: validateRegisterPassword,
                onChanged: (val) {
                  _userDataModel.password = val;
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
            SizedBox(height: _heightOne * 10,),
            authFormFieldContainer(
              child: TextFormField(
                obscureText: true,
                validator: (val) => val == _userDataModel.password ? null
                    : "Password in both fields should match",
                onChanged: (val) {
                  _userDataModel.password = val;
                },
                decoration: authFormFieldFormatting(
                    hintText: "Confirm Password",
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
                onPressed: () async{
                  if(_formKey.currentState.validate()){
                    QuerySnapshot read = await ref
                        .where("username", isEqualTo: _userDataModel.username)
                        .get();
                    if(read.size != 0){
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Username already exists')
                          )
                      );
                    }
                    else{
                      await _userAuth.registerUserWithEmail(
                          email: _userDataModel.email,
                          password: _userDataModel.password,
                          username: _userDataModel.username
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
                                  builder: (_) =>  MainScreenWrapper(
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
                    }
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
                    horizontal: _size.width * 0.29
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.orange.withOpacity(0.75),
                  ),
                )
            ),
            SizedBox(height: _heightOne * 15,),
            Text(
              "Or Register With",
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
                          _registerForm = false;
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
                          _registerForm = false;
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
            ),
            SizedBox(height: _heightOne * 20,),
            InkWell(
              onTap: (){
                widget.changeMethod(true);
              },
              child: Text(
                "Already Have an account? \nTap here to login.",
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
