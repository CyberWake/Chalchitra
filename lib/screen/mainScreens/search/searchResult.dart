import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/screen/screenImports.dart';
import 'package:Chalchitra/model/modelImports.dart';
import 'package:Chalchitra/database/databaseImports.dart';
import 'package:Chalchitra/imports.dart';

class SearchResult extends StatelessWidget {
  final UserDataModel eachUser;
  String uid;
  SearchResult(this.eachUser);

  final UserInfoStore _userInfoStore = UserInfoStore();
  final UserAuth _userAuth = UserAuth();

  Future<bool> checkIfAlreadyFollowing() async {
    bool result = await _userInfoStore.checkIfAlreadyFollowing(uid: uid);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Widget called---------------------------------------------------------------------');
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.push(
                context,
                Platform.isIOS
                    ? CupertinoPageRoute(
                        builder: (_) => SearchProfile(
                              uid: eachUser.id,
                            ))
                    : MaterialPageRoute(
                        builder: (_) => SearchProfile(
                              uid: eachUser.id,
                            )));
          },
          child: Platform.isIOS
              ? Material(color: AppTheme.primaryColor, child: profileTile())
              : profileTile(),
        ),
        Center(
          child: Container(
            height: 1.0,
            color: Colors.white54,
            width: MediaQuery.of(context).size.width - 20,
          ),
        ),
      ],
    );
  }

  Widget profileTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor,
        backgroundImage: eachUser.photoUrl != null
            ? CachedNetworkImageProvider(eachUser.photoUrl)
            : CachedNetworkImageProvider('https://via.placeholder.com/150'),
      ),
      title: Text(
        eachUser.displayName == null ? eachUser.username : eachUser.displayName,
        style: TextStyle(
          color: AppTheme.pureWhiteColor,
          fontSize: 17,
          letterSpacing: 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        eachUser.username == null ? '' : eachUser.username,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: RaisedButton(
        color: AppTheme.pureWhiteColor,
        onPressed: () => print('Following'),
        child: eachUser.following > 0 ? Text('Following') : Text('Follow'),
      ),
    );
  }
}
