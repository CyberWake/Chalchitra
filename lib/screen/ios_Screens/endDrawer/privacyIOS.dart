import 'package:flutter/cupertino.dart';

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
      navigationBar: CupertinoNavigationBar(middle: Text("Privacy"), backgroundColor: AppTheme.backgroundColor,),
      child: widget.privacyBody,
    );
  }
}
