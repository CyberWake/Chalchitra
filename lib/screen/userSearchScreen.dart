import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wowtalent/screen/profileScreen.dart';

class SearchUser extends StatefulWidget {
  SearchUser({Key key}) : super(key: key);

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser>
    with AutomaticKeepAliveClientMixin<SearchUser> {
  TextEditingController searchtextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  final ref = Firestore.instance.collection('WowUsers');
  User user;

  clearText() {
    searchtextEditingController.clear();
  }

  submitSearch(String userstr) {
    Future<QuerySnapshot> allUsers = ref
        .where("displayName", isGreaterThanOrEqualTo: userstr)
        .getDocuments();

    setState(() {
      futureSearchResult = allUsers;
    });
  }

  Container resultNotFound() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
          child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Icon(
            Icons.group,
            color: Colors.grey,
            size: 200,
          ),
          Text(
            'Search User',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 65),
          )
        ],
      )),
    );
  }

  foundUsers() {
    return FutureBuilder(
        future: futureSearchResult,
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<SearchResult> searchUserResult = [];
          dataSnapshot.data.documents.forEach((document) {
            User eachUser = User.fromDocument(document);
            SearchResult searchResult = SearchResult(eachUser);
            searchUserResult.add(searchResult);
          });

          return ListView(children: searchUserResult);
        });
  }

  bool get wantKeepAlive => true;

  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        style: TextStyle(fontSize: 18, color: Colors.black),
        controller: searchtextEditingController,
        decoration: InputDecoration(
            hintText: "Search ...",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 38.0,
            ),
            suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: clearText)),
        onFieldSubmitted: submitSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchPageHeader(),
      body: futureSearchResult == null ? resultNotFound() : foundUsers(),
    );
  }
}

class SearchResult extends StatelessWidget {
  final User eachUser;
  SearchResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(13),
      child: Container(
          child: Column(
        children: <Widget>[
          GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfilePage(
                            uid: eachUser.id,
                          ))),
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: eachUser.photoUrl != null
                        ? CachedNetworkImageProvider(eachUser.photoUrl)
                        : CachedNetworkImageProvider(
                            'https://via.placeholder.com/150')),
                title: Text(eachUser.displayName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                subtitle: Text(
                  eachUser.username == null ? '' : eachUser.username,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ))
        ],
      )),
    );
  }
}
