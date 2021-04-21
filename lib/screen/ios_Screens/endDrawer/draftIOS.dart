import 'package:flutter/cupertino.dart';

import '../../../model/theme.dart';

class DraftIOS extends StatefulWidget {
  Widget bodyContent;
  DraftIOS({this.bodyContent});
  @override
  _DraftIOSState createState() => _DraftIOSState();
}

class _DraftIOSState extends State<DraftIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Drafts"),
        backgroundColor: AppTheme.backgroundColor,
      ),
      child: widget.bodyContent,
    );
  }
}
