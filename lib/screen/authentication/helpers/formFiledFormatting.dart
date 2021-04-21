import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';

class FormFieldFormatting {
  static formFieldFormatting(
      {String hintText, double fontSize, Widget suffixIcon}) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      hintText: hintText,
      errorMaxLines: 3,
      hintStyle: TextStyle(color: AppTheme.primaryColor, fontSize: fontSize),
      errorStyle: TextStyle(fontSize: fontSize, color: Colors.deepOrangeAccent),
    );
  }

  static formFieldContainer({Widget child, double leftPadding}) {
    return Container(
      padding: EdgeInsets.only(left: leftPadding),
      decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(15.0)),
      child: child,
    );
  }
}
