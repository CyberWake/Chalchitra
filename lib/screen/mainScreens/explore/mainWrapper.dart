import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/explore/categories.dart';
import 'package:wowtalent/screen/mainScreens/explore/categoryWrapper.dart';
import 'package:wowtalent/screen/mainScreens/explore/explore.dart';
import 'package:wowtalent/screen/mainScreens/explore/exploreWrapper.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';

class ExplorePageWrapper extends StatefulWidget {
  @override
  _ExplorePageWrapperState createState() => _ExplorePageWrapperState();
}

class _ExplorePageWrapperState extends State<ExplorePageWrapper> {
  int currentIndex = 0;
  int currentVideo = 0;
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    print('widget main called');
    Size _size = MediaQuery.of(context).size;
    return SafeArea(
      child:DefaultTabController(
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
                    "Explore",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Tab(
                  child: Text("Categories", style: TextStyle(fontSize: 20)),
                )
              ],
            ),
            Expanded(
                child: TabBarView(
              children: [ExploreWrapperr(), CategoryWrapper()],
            ))
          ],
        ),
      ),
    ));
  }
}
