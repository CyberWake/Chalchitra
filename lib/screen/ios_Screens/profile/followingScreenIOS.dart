import 'package:flutter/cupertino.dart';
import 'package:Chalchitra/imports.dart';

class FollowingScreenIOS extends StatefulWidget {
  Widget followingBody;
  FollowingScreenIOS({Key key, this.followingBody}) : super(key: key);
  @override
  _FollowingScreenIOSState createState() => _FollowingScreenIOSState();
}

class _FollowingScreenIOSState extends State<FollowingScreenIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      key: widget.key,
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Following'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      child: widget.followingBody,
    );
  }
}
