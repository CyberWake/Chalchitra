import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/screen/mainScreens/search/searchResult.dart';

class SearchUser extends StatefulWidget {
  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final thumbWidth = 100;
  final thumbHeight = 150;

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  final ref = FirebaseFirestore.instance.collection('WowUsers');
  UserDataModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.purple.withOpacity(0.5))
                ),
                boxShadow: [BoxShadow(
                  offset: Offset(0, 2),
                  color: Colors.grey,
                  blurRadius: 8
                )]
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.purple.shade400,
                      ),
                      onPressed: () => Navigator.pop(context)
                  ),
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      controller: searchTextEditingController,
                      decoration: InputDecoration(
                          hintText: "Search By Username",
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5)
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                              icon: Icon(
                                  Icons.clear,
                                  color: Colors.purple.shade400
                              ),
                              onPressed: () =>
                                  searchTextEditingController.clear(),
                          )
                      ),
                      onFieldSubmitted: (String username) {
                        Future<QuerySnapshot> allUsers = ref
                            .where("displayName", isGreaterThanOrEqualTo: username)
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
              color: Colors.purple.shade300,
              size: 40,
          ),
          SizedBox(width: 20,),
          Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.purple.shade300,
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
              backgroundColor: Colors.purple.shade400,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade300),
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