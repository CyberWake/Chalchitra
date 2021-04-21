import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/ios_Screens/search/searchIOS.dart';
import 'package:wowtalent/screen/mainScreens/search/searchResult.dart';

class SearchUser extends StatefulWidget {
  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final thumbWidth = 100;
  final thumbHeight = 150;
  bool isFound = false;
  var queryResultSet = [];
  List<UserDataModel> searchUserResult = [];
  String search = "";
  UserInfoStore searchUser = UserInfoStore();
  SearchResult searchResult;
  QuerySnapshot searchKeyQuery;
  TextEditingController searchTextEditingController = TextEditingController();
  //Future<QuerySnapshot> futureSearchResult;
  //final ref = FirebaseFirestore.instance.collection('WowUsers');
  UserDataModel user;

  initiateSearch(searchUsername) async {
    if (searchUsername.length == 0) {
      setState(() {
        queryResultSet = [];
        searchUserResult = [];
      });
    }

    var capitalizedValue = searchUsername.toUpperCase();

    if (queryResultSet.length == 0 && searchUsername.length == 0 ||
        searchUsername.length == 1) {
      print('running1');
      if (searchUsername.length != 0) {
        searchKeyQuery = await searchUser.searchByUserName(searchUsername);
      }
      searchUserResult = [];
      for (int i = 0; i < searchKeyQuery.docs.length; ++i) {
        queryResultSet.add(searchKeyQuery.docs[i].data());
        if (searchKeyQuery.docs[i]
            .data()['username']
            .toUpperCase()
            .startsWith(capitalizedValue)) {
          UserDataModel eachUser =
              UserDataModel.fromDocument(searchKeyQuery.docs[i]);
          searchUserResult.add(eachUser);
          setState(() {
            isFound = true;
          });
        }
      }
      if (searchKeyQuery.size == 0) {
        setState(() {
          isFound = false;
        });
      }
    } else {
      print('running2');
      searchUserResult = [];
      for (int i = 0; i < searchKeyQuery.docs.length; ++i) {
        queryResultSet.add(searchKeyQuery.docs[i].data());
        if (searchKeyQuery.docs[i]
            .data()['username']
            .toUpperCase()
            .startsWith(capitalizedValue)) {
          UserDataModel eachUser =
              UserDataModel.fromDocument(searchKeyQuery.docs[i]);
          searchUserResult.add(eachUser);
          if (searchUserResult.length == 0) {
            isFound = false;
          }
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? SearchIOS(
            searchBody: searchBody(),
          )
        : Scaffold(
            backgroundColor: AppTheme.primaryColor,
            extendBody: false,
            body: searchBody(),
          );
  }

  Widget searchField(){
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(bottom: 20, left: 15, right: 15),
      height: 70,
      color: AppTheme.primaryColor,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Material(
              type: MaterialType.button,
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              color: Colors.transparent,
              child: TextFormField(
                controller: searchTextEditingController,
                onChanged: (String usernameIndex) {
                            if (usernameIndex.length == 0) {
                              searchTextEditingController.clear();
                              searchUserResult = [];
                              search = "";
                              setState(() {
                                searchUserResult = [];
                                search = "";
                                isFound = false;
                              });
                            }
                            print("Username Index: $usernameIndex");
                            initiateSearch(usernameIndex);
                          },
                decoration: InputDecoration(
                    hintText: "Search by Username",

                    // contentPadding: EdgeInsets.all(10),
                    focusColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.white)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.white)),
                    fillColor: AppTheme.pureWhiteColor,
                    filled: true,
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                                    searchTextEditingController.clear();
                                    searchUserResult = [];
                                    search = "";
                                    setState(() {});
                                  },
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBody() {
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          Offset offset = details.velocity.pixelsPerSecond;
          print(offset);
          if (offset.dx > 0) {
            print(offset.dx);
            Navigator.pop(context);
          }
        },
        child: Container(
          color: AppTheme.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField(),
              Expanded(
                  child: isFound
                      ? ListView.builder(
                          itemCount: searchUserResult.length,
                          itemBuilder: (BuildContext context, int index) {
                            // print(
                            //     "${user.id}--------------------------------YYYYYYYY-------------------");
                            return SearchResult(searchUserResult[index]);
                          }
                          // tempSearchStore == null ? resultNotFound() : foundUsers(),
                          )
                      : resultNotFound()),
            ],
          ),
        ),
      ),
    );
  }

  Widget resultNotFound() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.group,
            color: AppTheme.primaryColor,
            size: 40,
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            "Search User",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 25),
          )
        ]);
  }
}
