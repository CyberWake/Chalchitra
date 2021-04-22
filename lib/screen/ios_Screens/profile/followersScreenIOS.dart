import 'package:flutter/cupertino.dart';
import 'package:Chalchitra/imports.dart';

class FollowersScreenIOS extends StatefulWidget {
  Widget followersBody;
  FollowersScreenIOS({this.followersBody});
  @override
  _FollowersScreenIOSState createState() => _FollowersScreenIOSState();
}

class _FollowersScreenIOSState extends State<FollowersScreenIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Followers'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      child: widget.followersBody,
    );
  }
}
