import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/widgets/loadingTiles.dart';
import 'package:wowtalent/widgets/noDataTile.dart';
import 'package:wowtalent/widgets/notificationCard.dart';

class ActivityPage extends StatefulWidget {
  final String uid;
  ActivityPage({this.uid});
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  UserInfoStore _userInfoStore = UserInfoStore();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.backgroundColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('Activity'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: bodyContent(),
    );
  }

  Widget bodyContent() {
    return Material(
      child: FutureBuilder(
        future: _userInfoStore.getActivityFeed(uid: widget.uid),
        builder: (context, snap) {
          print(snap.data);
          if (snap.connectionState == ConnectionState.waiting ||
              !snap.hasData) {
            return LoadingCards();
          } else if (snap.data.documents.length == 0) {
            return NoDataTile(
              showButton: true,
              isActivity: true,
              titleText: "Your Activity",
              bodyText: "\n\nAll your app notifications will show up here.",
              subBodyText:
                  "\n\nGo engage with Creators: Like, Follow, Comment and Rate their Talent\n",
              buttonText: "Explore Talent",
            );
          }
          return ListView.builder(
            itemCount: snap.data.documents.length,
            itemBuilder: (context, index) {
              return NotificationCard(
                type: snap.data.documents[index]['type'],
                from: snap.data.documents[index]["from"],
                videoId: snap.data.documents[index]['type'] == "follow"
                    ? ""
                    : snap.data.documents[index]['videoID'],
              );
            },
          );
        },
      ),
    );
  }
}
