import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../mainScreens/search/search.dart';

class CategoryIOS extends StatefulWidget {
  String categoryName;
  Widget categoryBody;

  CategoryIOS({this.categoryBody,this.categoryName});

  @override
  _CategoryIOSState createState() => _CategoryIOSState();
}

class _CategoryIOSState extends State<CategoryIOS> {
  Size _size;
  double _widthOne;
  double _iconOne;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _iconOne = (_size.height * 0.066) / 50;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          middle: Text(widget.categoryName),
          trailing: CupertinoButton(
            padding:
            EdgeInsets.symmetric(vertical: 0, horizontal: _widthOne),
            child: Icon(
              CupertinoIcons.search,
              size: _iconOne * 30,
            ),
            onPressed: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (_) => SearchUser()));
            },
          ),
        ),
        child: widget.categoryBody,
    );
  }
}
