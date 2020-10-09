import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  String search = "";

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  final ref = FirebaseFirestore.instance.collection('WowUsers');
  UserDataModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                border: Border(
                  bottom: BorderSide(color: Colors.orange.withOpacity(0.5))
                ),
                boxShadow: [BoxShadow(
                  offset: Offset(0, 2),
                  color: AppTheme.pureWhiteColor.withOpacity(0.2),
                  blurRadius: 8
                )]
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.orange.shade400,
                      ),
                      onPressed: () => Navigator.pop(context)
                  ),
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(fontSize: 18, color: AppTheme.pureWhiteColor),
                      controller: searchTextEditingController,
                      decoration: InputDecoration(
                          hintText: "Search By Username",
                          hintStyle: TextStyle(
                              color: AppTheme.pureWhiteColor
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                              icon: Icon(
                                  Icons.clear,
                                  color: Colors.orange.shade400
                              ),
                              onPressed: () {
                                searchTextEditingController.clear();
                                search = "";
                              }
                          )
                      ),
                      onFieldSubmitted: (String username) {
                        search = username;
                        Future<QuerySnapshot> allUsers = ref
                            .where("username", isGreaterThanOrEqualTo: username)
                            .get();
                        setState(() {
                          futureSearchResult = allUsers;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: futureSearchResult == null ? resultNotFound() : foundUsers(),
            )
          ],
        ),
      )
    );
  }

  Widget resultNotFound() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
              Icons.group,
              color: Colors.orange.shade300,
              size: 40,
          ),
          SizedBox(width: 20,),
          Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.orange.shade300,
                  fontWeight: FontWeight.w500,
                  fontSize: 25
              ),
          )
        ]
    );
  }

  FutureBuilder foundUsers() {
    return FutureBuilder(
        future: futureSearchResult,
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return LinearProgressIndicator(
              backgroundColor: Colors.orange.shade400,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade300),
            );
          }
          List<SearchResult> searchUserResult = [];
          dataSnapshot.data.documents.forEach((document) {
            UserDataModel eachUser = UserDataModel.fromDocument(document);
            SearchResult searchResult = SearchResult(eachUser);
            searchUserResult.add(searchResult);
          });

          return ListView(children: searchUserResult);
        });
  }
}