import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormFieldFormatting{
  static formFieldFormatting({String hintText, double fontSize}){
    return InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      hintText: hintText,
      errorMaxLines: 3,
      hintStyle: TextStyle(
          color: Colors.orange.withOpacity(0.75),
          fontSize: fontSize
      ),
      errorStyle: TextStyle(
          fontSize: fontSize
      ),
    );
  }

  static formFieldContainer({Widget child, double leftPadding}){
    return Container(
      padding: EdgeInsets.only(
          left: leftPadding
      ),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.orange.withOpacity(0.75)
          ),
          borderRadius: BorderRadius.circular(15.0)
      ),
      child: child,
    );
  }
}