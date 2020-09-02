import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/notifier/auth_notifier.dart';
import 'package:wowtalent/screen/editProfileScreen.dart';
import 'package:wowtalent/model/user.dart';

import '../model/video_info.dart';
import '../video_uploader_widget/player.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
import '../database/firebase_provider.dart';

class ProfilePage extends StatefulWidget {
  final String url =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  final String uid;

  ProfilePage({@required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Fetching user atteributes from the user model

  User user;

  // Attributes

  bool loading = false;
  String _username;
  String currentUserID;
  int totalFollowers = 0;
  int totalFollowings = 0;
  int totalPost = 0;
  bool following = false;
  String currentUserImgUrl;
  String currentUserName;

  //Collection for followers

  final followerRef = Firestore.instance.collection('followers');

  //Collection for following

  final followingRef = Firestore.instance.collection('following');

  //collection for ActivityFeed

  final activityRef = Firestore.instance.collection('activity feed');

  //user video posts parameters
  final thumbWidth = 100;
  final thumbHeight = 150;

  List<VideoInfo> _videos = <VideoInfo>[];

  //Intialize initState cycle

  void initState() {
    super.initState();
    getCurrentUserID();
    // getAllFollowers();
    // getAllFollowing();
    checkIfAlreadyFollowing();
    FirebaseProvider.listenToVideos((newVideos) {
      setState(() {
        _videos = newVideos;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 35),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back_ios)),
                        widget.uid == authNotifier.user.uid
                            ? IconButton(
                                onPressed: () => signOut(authNotifier),
                                icon: Icon(
                                  Icons.power_settings_new,
                                  color: Colors.black,
                                ),
                              )
                            : Text(''),
                      ],
                    ),
                  ),
                  getProfileTopView(context),
                ],
              ),
             Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(
                   topRight: Radius.circular(20),
                   topLeft: Radius.circular(20),
                 ),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.grey.withOpacity(0.1),
                     offset: Offset(0.0, -10.0), //(x,y)
                     blurRadius: 10.0,
                   ),
                 ],
               ),
               height: size.height * 0.4423,
               width: size.width,
               margin: EdgeInsets.only(
                   top: size.height * 0.48
               ),
               padding: EdgeInsets.only(
                 top: size.height * 0.1,
                 left: size.width * 0.05,
                 right: size.width * 0.05
               ),
               child: widget.uid == authNotifier.user.uid ? Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Wrap(
                     spacing: 1,
                     runSpacing: 1,
                     children: List.generate(_videos.length, (index) {
                       print(_videos.length);
                       final video = _videos[index];
                       print(video);
                       Image image = Image.network(video.thumbUrl);
                       return GestureDetector(
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) {
                                 return Player(
                                   video: video,
                                 );
                               },
                             ),
                           );
                         },
                         child: Container(
                           width: size.width * 0.2,
                           height: size.height * 0.2,
                           margin: EdgeInsets.all(5),
                           decoration: BoxDecoration(
                               color: Colors.red,
                               image: DecorationImage(
                                   image: NetworkImage(video.thumbUrl),
                                   fit: BoxFit.cover
                               ),
                             borderRadius: BorderRadius.circular(10.5),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.grey.withOpacity(0.2),
                                 offset: Offset(0.0, 10.0), //(x,y)
                                 blurRadius: 10.0,
                               ),
                             ],
                           ),
                         ),
                       );
                     }),
                   ),
                 ],
               ) : Text(""),
             ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: size.height * 0.27
                    ),
                    width: size.width * 0.9,
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10)
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            user != null ? Text(
                              user.bio,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ) : Container(),
                            SizedBox(
                              height: 15,
                            ),
                            createButton(),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(totalPost, "Photos"),
                                getFollowers(),
                                getFollowings()
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ) ,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Getting Followers

  // getAllFollowers() async {
  //   QuerySnapshot querySnapshot = await followerRef
  //       .document(widget.uid)
  //       .collection('userFollowers')
  //       .getDocuments();

  //   setState(() {
  //     totalFollowers = querySnapshot.documents.length;
  //   });
  // }

  getFollowers() {
    return new StreamBuilder(
        stream: followerRef
            .document(widget.uid)
            .collection('userFollowers')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return new SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Hexcolor('#F23041')),
                    ),
                    Text(
                      'Followers',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ));
          }

          return new SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    snapshot.data.documents.length.toString(),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Hexcolor('#F23041')),
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ));
        });
  }

  // Getting Following Users

  // getAllFollowing() async {
  //   QuerySnapshot querySnapshot = await followingRef
  //       .document(widget.uid)
  //       .collection('userFollowing')
  //       .getDocuments();

  //   setState(() {
  //     totalFollowings = querySnapshot.documents.length;
  //   });
  // }

  getFollowings() {
    return new StreamBuilder(
        stream: followingRef
            .document(widget.uid)
            .collection('userFollowing')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return new SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Hexcolor('#F23041')),
                    ),
                    Text(
                      'Following',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ));
          }

          return new SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    snapshot.data.documents.length.toString(),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Hexcolor('#F23041')),
                  ),
                  Text(
                    'Following',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ));
        });
  }

  // Checking if already following

  checkIfAlreadyFollowing() async {
    await FirebaseAuth.instance.currentUser().then((currentUser) => {
      currentUserID = currentUser.uid,
    });
    DocumentReference querySnapshot = activityRef
        .document(widget.uid)
        .collection('activityItems')
        .document(currentUserID);

    DocumentSnapshot snap = await querySnapshot.get();
    setState(() {
      following = snap.exists;
    });
  }

  //cotrolFollowUsers managae follow users of the current users

  controlFollowUsers() {
    setState(() {
      following = true;
    });

    followerRef
        .document(widget.uid)
        .collection('userFollowers')
        .document(currentUserID)
        .setData({
      "userID": currentUserID,
      "displayName": currentUserName,
      "ownerID": widget.uid,
      "timestamp": DateTime.now()
    });

    followingRef
        .document(currentUserID)
        .collection('userFollowing')
        .document(widget.uid)
        .setData({});

    activityRef
        .document(widget.uid)
        .collection("activityItems")
        .document(currentUserID)
        .setData({
      "type": "follow",
      "ownerID": widget.uid,
      "displayName": currentUserName,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUserImgUrl,
      "userID": currentUserID
    });
  }

  // Controlling unfollow users

  controlUnfollowUsers() {
    setState(() {
      following = false;
    });

    followerRef
        .document(widget.uid)
        .collection("userFollowers")
        .document(currentUserID)
        .get()
        .then((document) => {
      if (document.exists) {document.reference.delete()}
    });

    followingRef
        .document(currentUserID)
        .collection("userFollowing")
        .document(widget.uid)
        .get()
        .then((document) => {
      if (document.exists) {document.reference.delete()}
    });

    activityRef
        .document(widget.uid)
        .collection('activityItems')
        .document(currentUserID)
        .get()
        .then((document) => {
      if (document.exists) {document.reference.delete()}
    });
  }

  // Getting Current User ID

  getCurrentUserID() async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    String uid = firebaseUser.uid;
    String url = firebaseUser.photoUrl;
    String displayName = firebaseUser.displayName;
    setState(() {
      currentUserID = uid;
      currentUserImgUrl = url;
      currentUserName = displayName;
    });

    print('User ID : $currentUserID');
  }

  // Getting top view of profile like displayName, username, bio , folllowers and following

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

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  offset: Offset(0.0, 20.0), //(x,y)
                  blurRadius: 10.0,
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: widget.url,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            user.photoUrl != null ?
                            user.photoUrl : widget.url
                        ),
                        radius: 40,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName != null ? user.displayName : "WowTalent",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Text(
                                '$_username',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50,)
              ],
            ),
          );
        });
  }

  // Dynamic button

  createButton() {
    bool userProfile = currentUserID == widget.uid;
    if (userProfile) {
      return createButtonTitleORFunction(
          title: 'Edit Profile', function: gotoEditProfile);
    } else if (following) {
      return createButtonTitleORFunction(
          title: 'Unfollow', function: controlUnfollowUsers);
    } else if (!following) {
      return createButtonTitleORFunction(
          title: 'Follow', function: controlFollowUsers);
    }
  }

  // Go to edit profile page

  gotoEditProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditProfilePage(
              uid: currentUserID,
            )));
  }

  // Dynamic container to create title and performing function

  Container createButtonTitleORFunction({String title, Function function}) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: RaisedButton(
            color: Colors.redAccent.withOpacity(.88) ,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(15)
                )
            ),
            onPressed: function,
            child: Container(
              width: 150,
              height: 30,
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: following ? Hexcolor('#F23041') : Colors.white,
                      fontSize: 16
                  )
              ),
              alignment: Alignment.center,
            )));
  }

  SingleChildScrollView buildPictureCard() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      //spacing: 1,
      //runSpacing: 1,
      child: Column(
        children: List.generate(_videos.length, (index) {
          final video = _videos[index];
          print(video);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Player(
                      video: video,
                    );
                  },
                ),
              );
            },
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                width: (size.width - 3) / 3,
                height: (size.width - 3) / 3,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                        image: NetworkImage(video.thumbUrl),
                        fit: BoxFit.cover)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Column buildStatColumn(int value, String title) {
    return Column(
      children: [
        Text(
          value.toString(),
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
