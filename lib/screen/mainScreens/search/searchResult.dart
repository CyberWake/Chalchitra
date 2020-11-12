import 'package:animations/animations.dart';
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
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 0.0),
        color: AppTheme.backgroundColor,
        child: Column(
          children: <Widget>[
            OpenContainer(
              closedElevation: 0.0,
              closedColor: AppTheme.pureWhiteColor,
              tappable: true,
              transitionDuration: Duration(milliseconds: 500),
              openBuilder: (BuildContext context,
                  void Function({Object returnValue}) action) {
                FocusScope.of(context).requestFocus(FocusNode());
                return SearchProfile(
                  uid: eachUser.id,
                );
              },
              closedBuilder: (BuildContext context, void Function() action) {
                FocusScope.of(context).requestFocus(FocusNode());
                return ListTile(
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
                );
              },
            ),
            Divider(
              color: AppTheme.grey,
            ),
          ],
        ));
  }
}
