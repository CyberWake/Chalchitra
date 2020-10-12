import 'package:flutter/cupertino.dart';

class EditProfileIOS extends StatefulWidget {
  Widget editProfileBody;
  EditProfileIOS({this.editProfileBody});
  @override
  _EditProfileIOSState createState() => _EditProfileIOSState();
}

class _EditProfileIOSState extends State<EditProfileIOS> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: widget.editProfileBody,
    );
  }
}
