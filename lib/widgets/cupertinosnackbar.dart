import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';

Flushbar<dynamic> cupertinoSnackbar(BuildContext context, String msg) {
  return Flushbar(
    maxWidth: MediaQuery.of(context).size.width * 0.5,
    borderRadius: 20,
    messageText: Text(
      msg,
      textAlign: TextAlign.center,
    ),
    animationDuration: Duration(milliseconds: 500),
    flushbarPosition: FlushbarPosition.BOTTOM,
    flushbarStyle: FlushbarStyle.FLOATING,
    backgroundColor: CupertinoColors.systemGrey,
    duration: Duration(milliseconds: 2000),
    padding: EdgeInsets.all(10),
  )..show(context);
}
