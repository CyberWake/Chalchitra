import 'package:flutter/cupertino.dart';
import 'package:wowtalent/model/theme.dart';

class ActivityPageIOS extends StatefulWidget {
  Widget bodyContent;
  ActivityPageIOS({this.bodyContent});
  @override
  _ActivityPageIOSState createState() => _ActivityPageIOSState();
}

class _ActivityPageIOSState extends State<ActivityPageIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: widget.bodyContent,
      navigationBar: CupertinoNavigationBar(
        middle: Text("Activity"),
        backgroundColor: AppTheme.backgroundColor,
      ),
    );
  }
}
