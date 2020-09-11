import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  final String videoId;

  CommentsScreen({this.videoId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  double _heightOne;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: _heightOne * 20),
          height: _size.height,
          color: Colors.orange,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  bottom: _heightOne * 20,
                  top: _heightOne * 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _widthOne * 50,),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(child: Container()),
                    SizedBox(width: _widthOne * 100,)
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(top: _heightOne * 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                          )
                      ),
                  )
              ),
            ],
          )
      ),
    );
  }
}
