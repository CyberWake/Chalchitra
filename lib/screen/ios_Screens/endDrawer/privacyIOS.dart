import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/theme.dart';

class PrivacyIOS extends StatefulWidget {
  Widget privacyBody;
  PrivacyIOS({this.privacyBody});
  @override
  _PrivacyIOSState createState() => _PrivacyIOSState();
}

class _PrivacyIOSState extends State<PrivacyIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.primaryColor,
      navigationBar: CupertinoNavigationBar(
        trailing: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            GestureDetector(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.pureWhiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                }),
            Text(
              "Privacy",
              style: TextStyle(color: AppTheme.pureWhiteColor, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      child: widget.privacyBody,
    );
  }
}
