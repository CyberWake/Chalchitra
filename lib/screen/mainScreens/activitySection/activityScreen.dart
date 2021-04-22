import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';

class ActivityScreen extends StatefulWidget {
  String uid;
  ActivityScreen({this.uid});
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  UserInfoStore _userInfoStore = UserInfoStore();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
    _userInfoStore.updateAllNotif(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      child: Material(
        color: AppTheme.primaryColor,
        child: StreamBuilder(
          stream: _userInfoStore.getActivityFeed(uid: widget.uid),
          builder: (context, snap) {
            print(snap.data);
            if (snap.connectionState == ConnectionState.waiting ||
                !snap.hasData) {
              return LoadingCards();
            } else if (snap.data.documents.length == 0) {
              return Center(
                child: Text(
                  "No Notification",
                  style: TextStyle(color: AppTheme.secondaryColor),
                ),
              );
            }
            print(snap.data.documents[0]['read']);
            return ListView.separated(
              padding: EdgeInsets.only(left: 15.0, right: 15, bottom: 20),
              separatorBuilder: (_, __) => Divider(
                indent: 80,
                color: AppTheme.grey,
              ),
              itemCount: snap.data.documents.length,
              itemBuilder: (context, index) {
                return NotificationCard(
                  onTap: () async {
                    print("called notification read");
                    await _userInfoStore.updateNotif(
                        uid: widget.uid, doc: snap.data.documents[index]);
                  },
                  read: snap.data.documents[index]["read"],
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
      ),
    );
  }
}
