import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

authFormFieldFormatting({String hintText, double fontSize}){
  return InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    hintText: hintText,
    hintStyle: TextStyle(
        color: Colors.deepPurple.withOpacity(0.5),
        fontSize: fontSize
    ),
    errorStyle: TextStyle(
        fontSize: fontSize
    ),
  );
}

authFormFieldContainer({Widget child, double leftPadding}){
  return Container(
    padding: EdgeInsets.only(
        left: leftPadding
    ),
    decoration: BoxDecoration(
        border: Border.all(
            color: Colors.purple.withOpacity(0.5)
        ),
        borderRadius: BorderRadius.circular(15.0)
    ),
    child: child,
  );
}