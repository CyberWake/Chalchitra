import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';

class ActivityWrapper extends StatefulWidget {
  String uid;
  ActivityWrapper({this.uid});
  @override
  _ActivityWrapperState createState() => _ActivityWrapperState();
}

class _ActivityWrapperState extends State<ActivityWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: 1,
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverList(delegate: SliverChildListDelegate([Container()]))
              ];
            },
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  indicatorColor: AppTheme.secondaryColor,
                  labelColor: AppTheme.secondaryColor,
                  unselectedLabelColor: AppTheme.grey,
                  tabs: [
                    Tab(
                      child: Text(
                        "Messages",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Tab(
                      child: Text("Activity", style: TextStyle(fontSize: 20)),
                    )
                  ],
                ),
                Expanded(
                    child: TabBarView(
                  children: [
                    MessagesScreen(),
                    ActivityScreen(
                      uid: widget.uid,
                    )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
