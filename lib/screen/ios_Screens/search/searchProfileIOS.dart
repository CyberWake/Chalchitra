import 'package:flutter/cupertino.dart';

class SearchProfileIOS extends StatefulWidget {
  Widget searchProfileBody;
  SearchProfileIOS({this.searchProfileBody});
  @override
  _SearchProfileIOSState createState() => _SearchProfileIOSState();
}

class _SearchProfileIOSState extends State<SearchProfileIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: widget.searchProfileBody,
    );
  }
}
