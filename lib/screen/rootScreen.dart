import 'package:flutter/material.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/screen/homescreen.dart';
import 'package:wowtalent/screen/messageScreen.dart';
import 'package:wowtalent/screen/profileScreen.dart';
import 'package:wowtalent/screen/searchScreen.dart';
import 'package:wowtalent/screen/videoUploaderScreen.dart';
import 'package:wowtalent/theme/colors.dart';
import 'dart:math';
import 'package:hexcolor/hexcolor.dart';

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
      body: getBody(context),
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
            backgroundColor: Hexcolor('#F23041'),
            elevation: 15,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Hexcolor('#F29F05'),
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            getFooter(Icons.home, 0),
            getFooter(Icons.search, 1),
            getFooter(null, -1),
            Transform.rotate(
              angle: 180 * pi / 100,
              child: getFooter(Icons.send, 3),
            ),
            getFooter(Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    List<Widget> pages = [
      HomePage(),
      SearchPage(),
      //SearchUser(),
      VideoUploader(),
      Message(),
      ProfilePage(
        uid: UserAuth().user.uid,
      )
    ];
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getAppBar() {
    if (pageIndex == 0) {
      return AppBar(
        backgroundColor: Hexcolor('#F29F05'),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "WowTalent",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
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
      return null;
    } else {
      return null;
    }
  }

  Widget getFooter(IconData icon, int index) {
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
                color: index == pageIndex ? Hexcolor('#F23041') : Colors.white,
              )
            : Container(),
      ),
    );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
