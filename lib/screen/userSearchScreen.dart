import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wowtalent/model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wowtalent/screen/profileScreen.dart';
import 'package:wowtalent/data/search_json.dart';
import 'package:wowtalent/widgets/search_category_widget.dart';

class SearchUser extends StatefulWidget {
  SearchUser({Key key}) : super(key: key);

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
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

  SingleChildScrollView resultNotFound() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 20),
              child: Row(
                  children: List.generate(searchCategories.length, (index) {
                return CategoryStoryItem(
                  name: searchCategories[index],
                );
              })),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Wrap(
          spacing: 1,
          runSpacing: 1,
          children: List.generate(searchImages.length, (index) {
            return Container(
              width: (size.width - 3) / 3,
              height: (size.width - 3) / 3,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(searchImages[index]),
                      fit: BoxFit.cover)),
            );
          }),
        )
      ]),
    );
  }

  foundUsers() {
    return FutureBuilder(
        future: futureSearchResult,
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return LinearProgressIndicator();
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

  // bool get wantKeepAlive => true;

  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        style: TextStyle(fontSize: 18, color: Colors.black),
        controller: searchtextEditingController,
        decoration: InputDecoration(
            hintText: "Search ...",
            hintStyle: TextStyle(color: Colors.grey),
            // enabledBorder: UnderlineInputBorder(
            //     borderSide: BorderSide(color: Colors.grey)),
            // focusedBorder: UnderlineInputBorder(
            //     borderSide: BorderSide(color: Colors.black)),
            border: InputBorder.none,
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              color: Hexcolor('#F23041'),
              size: 38.0,
            ),
            suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Hexcolor('#F23041')),
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
