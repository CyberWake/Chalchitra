import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


// For formatting text inout fields
const enabled =  OutlineInputBorder(
  borderSide: BorderSide(color: Colors.blue, width: 2),
);

const focused =  OutlineInputBorder(
  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2),
);

const textInputFormatting = InputDecoration(
  fillColor: Colors.white,
  filled : true,
  errorBorder: enabled,
  focusedErrorBorder:focused,
  enabledBorder: enabled,
  focusedBorder: focused,
);

const authInputFormatting = InputDecoration(
  fillColor: Colors.white,
  filled : true,
  border: InputBorder.none,
);
