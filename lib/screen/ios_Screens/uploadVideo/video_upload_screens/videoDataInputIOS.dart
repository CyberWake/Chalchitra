import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';

class VideoDataInputIOS extends StatefulWidget {
  Widget dataInputBody;
  Function uploadDraftToServer;
  bool draftSaved;
  VideoDataInputIOS({this.dataInputBody,this.draftSaved,this.uploadDraftToServer});
  @override
  _VideoDataInputIOSState createState() => _VideoDataInputIOSState();
}

class _VideoDataInputIOSState extends State<VideoDataInputIOS> {
  Size _size;
  double _iconOne;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _iconOne = (_size.height * 0.066) / 50;
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.elevationColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.primaryColor,
        middle: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          height: 55,
          width: _size.width / 2.5,
          child: Image.asset('assets/images/appBarLogo1.png',fit: BoxFit.fitHeight,),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Icon(
            Icons.save,
            color: Colors.black,
            size: _iconOne * 30,
          ),
          onPressed: (){
            widget.draftSaved = true;
            widget.uploadDraftToServer();
          },
        ),

      ),
      child: widget.dataInputBody,
    );
  }
}
