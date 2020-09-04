import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wowtalent/model/user.dart';
import '../auth/auth_api.dart';

class UserInfoStore{
  UserDataModel _currentUserModel;
  static final CollectionReference _users = FirebaseFirestore.instance.collection('WowUsers');
  final _followers = FirebaseFirestore.instance.collection('followers');
  final _followings = FirebaseFirestore.instance.collection('following');
  final _activity = FirebaseFirestore.instance.collection('activity feed');

  static final UserAuth _userAuth = UserAuth();

  //Creating User Record in FireStore
  Future<bool> createUserRecord() async {
    try{
      // create a document for the user with the uid(user id)
      DocumentSnapshot userRecord = await _users.doc(_userAuth.user.uid).get();

      if (_userAuth.user != null) {
        if (userRecord.data == null) {
          Map<String, dynamic> userData = {
            "id": _userAuth.user.uid,
            "displayName": _userAuth.user.displayName,
            "email": _userAuth.user.email,
            "photoUrl": _userAuth.user.photoURL,
            "username": "",
            "bio": "",
            "followers": {},
            "following": {}
          };

          // no user record exists, time to create
          _users.doc(_userAuth.user.uid).set(userData);
          userRecord = await _users.doc(_userAuth.user.uid).get();
        }
        _currentUserModel = UserDataModel.fromDocument(userRecord);
      }

      return true;
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  Stream getFollowers({String uid}){
    return _followers
        .doc(uid)
        .collection('userFollowers')
        .snapshots();
  }

  Stream getFollowing({String uid}){
    return _followings
        .doc(uid)
        .collection('userFollowing')
        .snapshots();
  }

  Future<bool>checkIfAlreadyFollowing({String uid}) async {
    DocumentSnapshot documentSnapshot =
    await _activity
        .doc(uid)
        .collection('activityItems')
        .doc(_userAuth.user.uid).get();
    return documentSnapshot.exists;
  }

  Future followUser({String uid}) async{
    _followers
        .doc(uid)
        .collection('userFollowers')
        .doc(_userAuth.user.uid)
        .set({
      "userID": _userAuth.user.uid,
      "displayName": _userAuth.user.displayName,
      "ownerID": uid,
      "timestamp": DateTime.now()
    });

    _followings
        .doc(_userAuth.user.uid)
        .collection('userFollowing')
        .doc(uid)
        .set({});

    _activity
        .doc(uid)
        .collection("activityItems")
        .doc(_userAuth.user.uid)
        .set({
      "type": "follow",
      "ownerID": uid,
      "displayName": _userAuth.user.displayName,
      "timestamp": DateTime.now(),
      "userProfileImg": _userAuth.user.photoURL,
      "userID": _userAuth.user.uid
    });
  }

  Future unFollowUser({String uid}){
    _followers
        .doc(uid)
        .collection("userFollowers")
        .doc(_userAuth.user.uid)
        .get()
        .then((document) => {
      if (document.exists) {document.reference.delete()}
    });

    _followings
        .doc(_userAuth.user.uid)
        .collection("userFollowing")
        .doc(uid)
        .get()
        .then((document) => {
      if (document.exists) {document.reference.delete()}
    });

    _activity
        .doc(uid)
        .collection('activityItems')
        .doc(_userAuth.user.uid)
        .get()
        .then((document) => {
      if (document.exists) {document.reference.delete()}
    });
  }

  Stream getUserInfo({String uid}){
    return _users
        .doc(uid)
        .snapshots();
  }
}