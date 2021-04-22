import 'package:flutter/cupertino.dart';
import 'package:Chalchitra/imports.dart';

class SearchIOS extends StatefulWidget {
  Widget searchBody;
  SearchIOS({this.searchBody});
  @override
  _SearchIOSState createState() => _SearchIOSState();
}

class _SearchIOSState extends State<SearchIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.primaryColor,
      child: widget.searchBody,
    );
  }
}
