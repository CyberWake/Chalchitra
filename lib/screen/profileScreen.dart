import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/notifier/auth_notifier.dart';
import 'package:wowtalent/screen/editProfileScreen.dart';
import 'package:wowtalent/model/user.dart';

class ProfilePage extends StatefulWidget {
  final String url =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final String uid;

  ProfilePage({@required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user;
  bool loading = false;

  String _username;

  String currentUserID;

  void initState() {
    super.initState();
    getCurrentUserID();
  }

  getCurrentUserID() async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    String uid = firebaseUser.uid;
    setState(() {
      currentUserID = uid;
    });

    print('User ID : $currentUserID');
  }

  getProfileTopView(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('WowUsers')
            .document(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading");
          }
          user = User.fromDocument(snapshot.data);

          _username = user.username;

          return new Padding(
            padding: EdgeInsets.all(17),
            child: Column(
              children: <Widget>[
                Hero(
                  tag: widget.url,
                  child: Container(
                    margin: EdgeInsets.only(top: 5),
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 20,
                        )
                      ],
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            user.photoUrl != null ? user.photoUrl : widget.url),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  ' @$_username',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    user.displayName != null ? user.displayName : "WowTalent",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        });
  }

  controlFollowUsers() {
    print('follow tapped!!');
  }

  createButton() {
    bool userProfile = currentUserID == widget.uid;
    if (userProfile) {
      return createButtonTitleORFunction(
          title: 'Edit Profile', function: gotoEditProfile);
    }
  }

  gotoEditProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditProfilePage(
                  uid: currentUserID,
                )));
  }

  Container createButtonTitleORFunction({String title, Function function}) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: FlatButton(
            onPressed: function,
            child: Container(
              width: 245,
              height: 30,
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Hexcolor('#F23041'),
                      fontSize: 16)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Hexcolor('#F23041')),
                  borderRadius: BorderRadius.circular(6.0)),
            )));
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 35),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios)),
                FlatButton.icon(
                  onPressed: () => signOut(authNotifier),
                  label: Text('LogOut'),
                  icon: Icon(
                    Icons.face,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
          getProfileTopView(context),
          SizedBox(
            height: 10,
          ),
          createButton(),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStatColumn("53", "Photos"),
              buildStatColumn("223k", "Followers"),
              buildStatColumn("117", "Following"),
            ],
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8, top: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25))),
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 5 / 6,
                children: [
                  buildPictureCard(
                      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260"),
                  buildPictureCard(
                      "https://images.pexels.com/photos/132037/pexels-photo-132037.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260"),
                  buildPictureCard(
                      "https://images.pexels.com/photos/733475/pexels-photo-733475.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260"),
                  buildPictureCard(
                      "https://images.pexels.com/photos/268533/pexels-photo-268533.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260"),
                  buildPictureCard(
                      "https://images.pexels.com/photos/268533/pexels-photo-268533.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260"),
                  buildPictureCard(
                      "https://images.pexels.com/photos/268533/pexels-photo-268533.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Card buildPictureCard(String url) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(url),
            )),
      ),
    );
  }

  Column buildStatColumn(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Hexcolor('#F23041')),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
