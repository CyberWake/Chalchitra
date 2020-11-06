import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';

class SearchResult extends StatelessWidget {
  final UserDataModel eachUser;
  SearchResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
          color: AppTheme.backgroundColor,
          child: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => SearchProfile(
                                  uid: eachUser.id,
                                )));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: eachUser.photoUrl != null
                            ? CachedNetworkImageProvider(eachUser.photoUrl)
                            : CachedNetworkImageProvider(
                                'https://via.placeholder.com/150')),
                    title: Text(
                        eachUser.displayName == null
                            ? eachUser.username
                            : eachUser.displayName,
                        style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      eachUser.username == null ? '' : eachUser.username,
                      style: TextStyle(color: AppTheme.grey, fontSize: 13),
                    ),
                  )),
              Divider(
                color: AppTheme.grey,
              ),
            ],
          )),
    );
  }
}
