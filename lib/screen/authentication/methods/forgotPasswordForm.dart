import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'package:wowtalent/screen/authentication/helpers/validation.dart';

class ForgotPasswordForm extends StatefulWidget {
  final ValueChanged<AuthIndex> changeMethod;
  ForgotPasswordForm({this.changeMethod});
  @override
  ForgotPasswordFormState createState() => ForgotPasswordFormState();
}

class ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  UserDataModel _userDataModel = UserDataModel();
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: _heightOne * 10,),
            _emailField(),
            SizedBox(height: _heightOne * 15,),
            _submitButton(),
            SizedBox(height: _heightOne * 15,),
            InkWell(
              onTap: (){
                widget.changeMethod(AuthIndex.LOGIN);
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

  Widget _emailField(){
    return  FormFieldFormatting.formFieldContainer(
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

  Widget _submitButton(){
    return FlatButton(
        onPressed: () async{
          if(_formKey.currentState.validate()){

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
            horizontal: _size.width * 0.29
        ),
        child: Text(
          "Submit",
          style: TextStyle(
            color: Colors.orange.withOpacity(0.75),
          ),
        )
    );
  }
}
