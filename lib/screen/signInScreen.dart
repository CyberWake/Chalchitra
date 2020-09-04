import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/shared/loader.dart';

enum AuthMode { SignUp, Login }

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = new TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  bool loading = false;

  UserDataModel _user = UserDataModel();
  // String _message = 'Log in/out by pressing the buttons below.';
  static final FacebookLogin fbLogin = new FacebookLogin();
  UserAuth _userAuth = UserAuth();

  @override
  void initState() {
    super.initState();
  }

  void _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    if (_authMode == AuthMode.Login) {
      _userAuth.signInWithEmailAndPassword(
        email: _user.email,
        password: _user.password,
      );
      setState(() => loading = true);
    } else {
      _userAuth.registerUserWithEmail(
        email: _user.email,
        password: _user.password,
      );
      setState(() => loading = true);
    }
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Display Name",
        labelStyle: TextStyle(color: Colors.white54),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 26, color: Colors.white),
      cursorColor: Colors.white,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Display Name is required';
        }

        if (value.length < 5 || value.length > 12) {
          return 'Display Name must be betweem 5 and 12 characters';
        }

        return null;
      },
      onSaved: (String value) {
        _user.displayName = value;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: TextStyle(color: Colors.white54),
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 26, color: Colors.white),
      cursorColor: Colors.white,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email is required';
        }

        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }

        return null;
      },
      onSaved: (String value) {
        _user.email = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(fontSize: 26, color: Colors.white),
      cursorColor: Colors.white,
      obscureText: true,
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        }

        if (value.length < 5 || value.length > 20) {
          return 'Password must be betweem 5 and 20 characters';
        }

        return null;
      },
      onSaved: (String value) {
        _user.password = value;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Confirm Password",
        labelStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(fontSize: 26, color: Colors.white),
      cursorColor: Colors.white,
      obscureText: true,
      validator: (String value) {
        if (_passwordController.text != value) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building login screen");

    return loading
        ? Loader()
        : Scaffold(
            body: Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              decoration: BoxDecoration(color: Color(0xff34056D)),
              child: Form(
                autovalidate: true,
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(32, 96, 32, 0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Please Sign In",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 36, color: Colors.white),
                        ),
                        SizedBox(height: 32),
                        _authMode == AuthMode.SignUp
                            ? _buildDisplayNameField()
                            : Container(),
                        _buildEmailField(),
                        _buildPasswordField(),
                        _authMode == AuthMode.SignUp
                            ? _buildConfirmPasswordField()
                            : Container(),
                        SizedBox(height: 32),
                        ButtonTheme(
                          minWidth: 200,
                          child: RaisedButton(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                _authMode = _authMode == AuthMode.Login
                                    ? AuthMode.SignUp
                                    : AuthMode.Login;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        ButtonTheme(
                          minWidth: 200,
                          child: RaisedButton(
                            padding: EdgeInsets.all(10.0),
                            onPressed: () => _submitForm(),
                            child: Text(
                              _authMode == AuthMode.Login ? 'Login' : 'Signup',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ButtonTheme(
                          minWidth: 300,
                          child: RaisedButton(
                            onPressed: () async {
                              setState(() => loading = true);

                            },
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Login With Google",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ButtonTheme(
                          minWidth: 300,
                          child: RaisedButton(
                            onPressed: (){},
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Login With Facebook",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
