import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
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
    return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        extendBody: true,
        body: SafeArea(
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
              color: AppTheme.backgroundColor,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        border: Border(
                            bottom: BorderSide(
                                color: AppTheme.primaryColor.withOpacity(0.5))),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 2),
                              color: AppTheme.pureWhiteColor.withOpacity(0.2),
                              blurRadius: 8)
                        ]),
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: () => Navigator.pop(context)),
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                                fontSize: 18, color: AppTheme.pureWhiteColor),
                            controller: searchTextEditingController,
                            decoration: InputDecoration(
                                hintText: "Search By Username",
                                hintStyle:
                                    TextStyle(color: AppTheme.pureWhiteColor),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.clear,
                                        color: AppTheme.primaryColor),
                                    onPressed: () {
                                      searchTextEditingController.clear();
                                      searchUserResult = [];
                                      search = "";
                                      setState(() {});
                                    })),
                            onChanged: (String usernameIndex) {
                              if (usernameIndex.length == 0) {
                                setState(() {
                                  isFound = false;
                                });
                              }
                              print(usernameIndex);
                              initiateSearch(usernameIndex);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: isFound
                          ? ListView.builder(
                              itemCount: searchUserResult.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SearchResult(searchUserResult[index]);
                              }
                              // tempSearchStore == null ? resultNotFound() : foundUsers(),
                              )
                          : resultNotFound()),
                ],
              ),
            ),
          ),
        ));
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
