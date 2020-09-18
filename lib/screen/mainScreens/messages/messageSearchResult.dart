import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/screen/mainScreens/messages/messagesChatScreen.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';

class MessageSearchResult extends StatelessWidget {
  final UserDataModel eachUser;
  MessageSearchResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                            targetUID: eachUser.id,
                          )
                      )
                  ),
                  child: ListTile(
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
