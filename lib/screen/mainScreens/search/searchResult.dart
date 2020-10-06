import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          child: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: () => Navigator.push(
                      context, Platform.isIOS ? CupertinoPageRoute(builder: (_) => SearchProfile(
                    uid: eachUser.id,
                  )):
                      MaterialPageRoute(
                          builder: (_) => SearchProfile(
                            uid: eachUser.id,
                          ))),
                  child:Platform.isIOS ? Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: eachUser.photoUrl != null
                                ? CachedNetworkImageProvider(
                                eachUser.photoUrl
                            ) : CachedNetworkImageProvider(
                                'https://via.placeholder.com/150'
                            )
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                eachUser.displayName == null ? eachUser.username : eachUser.displayName,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            Text(
                              eachUser.username == null ? '' : eachUser.username,
                              style: TextStyle(decoration: TextDecoration.none,color: Colors.grey, fontSize: 13,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,size: 15,color: CupertinoColors.systemGrey,)
                      ],
                    ),
                  ) : ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: eachUser.photoUrl != null
                            ? CachedNetworkImageProvider(
                            eachUser.photoUrl
                        ) : CachedNetworkImageProvider(
                            'https://via.placeholder.com/150'
                        )
                    ),
                    title: Text(
                        eachUser.displayName == null ? eachUser.username : eachUser.displayName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    subtitle: Text(
                      eachUser.username == null ? '' : eachUser.username,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ))
            ],
          )),
    );
  }
}
