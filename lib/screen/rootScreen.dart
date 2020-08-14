import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wowtalent/screen/homescreen.dart';
import 'package:wowtalent/screen/profileScreen.dart';
import 'package:wowtalent/screen/searchScreen.dart';
import 'package:wowtalent/theme/colors.dart';

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      backgroundColor: white,
      body: getBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.grey[900],
            elevation: 15,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
              )
            ],
            // color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            getFooter(Icons.home, 0),
            getFooter(Icons.search, 1),
            getFooter(null, -1),
            getFooter(Icons.notifications, 3),
            getFooter(Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    List<Widget> pages = [
      HomePage(),
      SearchPage(),
      Center(
        child: Text(
          "Upload Page",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: black),
        ),
      ),
      Center(
        child: Text(
          "Activity Page",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: black),
        ),
      ),
      ProfilPage()
    ];
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getAppBar() {
    if (pageIndex == 0) {
      return AppBar(
        backgroundColor: appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // SvgPicture.asset(
            //   "assets/images/camera_icon.svg",
            //   width: 30,
            // ),
            Text(
              "WowTalent",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
            // SvgPicture.asset(
            //   "assets/images/message_icon.svg",
            //   width: 30,
            // ),
          ],
        ),
      );
    } else if (pageIndex == 1) {
      return null;
    } else if (pageIndex == 2) {
      return AppBar(
        backgroundColor: appBarColor,
        title: Text(
          "Upload",
          style: TextStyle(color: Colors.black),
        ),
      );
    } else if (pageIndex == 3) {
      return AppBar(
        backgroundColor: appBarColor,
        title: Text(
          "Activity",
          style: TextStyle(color: Colors.black),
        ),
      );
    } else {
      return null;
    }
  }

  Widget getFooter(IconData icon, int index) {
    List bottomItems = [
      pageIndex == 0
          ? "assets/images/home_active_icon.svg"
          : "assets/images/home_icon.svg",
      pageIndex == 1
          ? "assets/images/search_active_icon.svg"
          : "assets/images/search_icon.svg",
      pageIndex == 2
          ? "assets/images/upload_active_icon.svg"
          : "assets/images/upload_icon.svg",
      pageIndex == 3
          ? "assets/images/love_active_icon.svg"
          : "assets/images/love_icon.svg",
      pageIndex == 4
          ? "assets/images/account_active_icon.svg"
          : "assets/images/account_icon.svg",
    ];

    return GestureDetector(
      onTap: () {
        selectedTab(index);
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 5,
        height: 45,
        child: icon != null
            ? Icon(
                icon,
                size: 25,
                color: index == pageIndex ? Colors.black : Colors.grey[700],
              )
            : Container(),
      ),
    );

    // return Container(
    //   width: double.infinity,
    //   height: 80,
    //   decoration: BoxDecoration(color: appFooterColor),
    //   child: Padding(
    //     padding:
    //         const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 15),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: List.generate(bottomItems.length, (index) {
    //         return InkWell(
    //             onTap: () {
    //               selectedTab(index);
    //             },
    //             child: SvgPicture.asset(
    //               bottomItems[index],
    //               width: 27,
    //             ));
    //       }),
    //     ),
    //   ),
    // );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
