import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/userDataModel.dart';

import '../auth/userAuth.dart';

class UserInfoStore {
  UserDataModel _currentUserModel;
  static final CollectionReference _users =
  FirebaseFirestore.instance.collection('WowUsers');
  final _followers = FirebaseFirestore.instance.collection('followers');
  final _followings = FirebaseFirestore.instance.collection('following');
  final _activity = FirebaseFirestore.instance.collection('activity feed');
  final _chatUIDs = FirebaseFirestore.instance.collection('chatUIDs');
  final _allChats = FirebaseFirestore.instance.collection('allChats');
  final _notificationCenter =
  FirebaseFirestore.instance.collection("notifications");
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final UserAuth _userAuth = UserAuth();

  Future<bool> createUserRecord(
      {String username = "", BuildContext context}) async {
    try {
      String _fcmToken = await _fcm.getToken();
      DocumentSnapshot userRecord = await _users.doc(_userAuth.user.uid).get();
      if (_userAuth.user != null && _fcmToken != null) {
        if (!userRecord.exists) {
          Map<String, dynamic> userData = {
            "id": _userAuth.user.uid,
            "displayName": _userAuth.user.displayName,
            "email": _userAuth.user.email,
            "photoUrl": _userAuth.user.photoURL,
            "username": username,
            "bio": "Hello World!",
            "private": false,
            "searchKey": username.substring(0, 1).toUpperCase(),
            "followers": 0,
            "following": 0,
            "videoCount": 0,
            "fcmToken": _fcmToken
          };
          _users.doc(_userAuth.user.uid).set(userData);
          userRecord = await _users.doc(_userAuth.user.uid).get();
        }
        _currentUserModel = UserDataModel.fromDocument(userRecord);
        Provider.of<CurrentUser>(context, listen: false)
            .updateCurrentUser(_currentUserModel);
      }

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future updateToken({BuildContext context}) async {
    try {
      String _fcmToken = await _fcm.getToken();
      print("run");
      DocumentSnapshot userRecord = await _users.doc(_userAuth.user.uid).get();
      _users.doc(_userAuth.user.uid).update({'fcmToken': _fcmToken});
      userRecord = await _users.doc(_userAuth.user.uid).get();
      _currentUserModel = UserDataModel.fromDocument(userRecord);
      Provider.of<CurrentUser>(context, listen: false)
          .updateCurrentUser(_currentUserModel);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> updatePrivacy({String uid, bool privacy}) async {
    try {
      _users.doc(_userAuth.user.uid).update({
        "private": privacy,
      });
      return true;
    } on Exception catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> getPrivacy({String uid}) async {
    try {
      bool result;
      await _users
          .where("id", isEqualTo: uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          if (doc.data()['id'] == uid) {
            print("privacy in database " +
                doc.data()["private"].toString());
            result = doc.data()["private"];
          }
        })
      });
      print("result " + result.toString());
      return result;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> isUsernameNew({String username}) async {
    print(username);
    try {
      QuerySnapshot read =
      await _users.where("username", isEqualTo: username).get();

      if (read.size != 0) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> emailExists({String email}) async {
    print(email);
    try {
      QuerySnapshot read = await _users.where("email", isEqualTo: email).get();

      if (read.size != 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  searchByUserName(String searchIndex) {
    print('here');
    return _users
        .where('searchKey',
        isEqualTo: searchIndex.substring(0, 1).toUpperCase())
        .get();
  }

  Stream getFollowers({String uid}) {
    return _followers.doc(uid).collection('userFollowers').snapshots();
  }

  Stream getFollowing({String uid}) {
    return _followings.doc(uid).collection('userFollowing').snapshots();
  }

  Future getFollowingFuture({String uid}) {
    return _followings.doc(uid).collection("userFollowing").get();
  }

  Future<bool> checkIfAlreadyFollowing({String uid}) async {
    try {
      DocumentSnapshot documentSnapshot = await _followers
          .doc(uid)
          .collection('userFollowers')
          .doc(_userAuth.user.uid)
          .get();
      return documentSnapshot.exists;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<UserDataModel> getUserInformation({String uid}) async {
    try {
      DocumentSnapshot ds = await _users.doc(uid).get();
      return UserDataModel.fromDocument(ds);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> followUser({String uid}) async {
    try {
      await _followers
          .doc(uid)
          .collection('userFollowers')
          .doc(_userAuth.user.uid)
          .set({});
      await _users.doc(uid).update({"followers": FieldValue.increment(1)});

      await _followings
          .doc(_userAuth.user.uid)
          .collection('userFollowing')
          .doc(uid)
          .set({});
      await _users
          .doc(_userAuth.user.uid)
          .update({"following": FieldValue.increment(1)});

      await _activity
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
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> unFollowUser({String uid}) async {
    try {
      await _followers
          .doc(uid)
          .collection("userFollowers")
          .doc(_userAuth.user.uid)
          .get()
          .then((document) async => {
        if (document.exists) {await document.reference.delete()}
      });
      await _users.doc(uid).update({"followers": FieldValue.increment(-1)});

      await _followings
          .doc(_userAuth.user.uid)
          .collection("userFollowing")
          .doc(uid)
          .get()
          .then((document) async => {
        if (document.exists) {await document.reference.delete()}
      });
      await _users
          .doc(_userAuth.user.uid)
          .update({"following": FieldValue.increment(-1)});

      await _activity
          .doc(uid)
          .collection('user')
          .doc(_userAuth.user.uid)
          .get()
          .then((document) async => {
        if (document.exists) {await document.reference.delete()}
      });

      return Future.value(false);
    } catch (e) {
      print(e.toString());
      return Future.value(true);
    }
  }

  Future<bool> removeFollowingUser({String uid}) async {
    try {
      await _followings
          .doc(uid)
          .collection("userFollowing")
          .doc(_userAuth.user.uid)
          .get()
          .then((document) async => {
        if (document.exists) {await document.reference.delete()}
      });

      await _followers
          .doc(_userAuth.user.uid)
          .collection("userFollowers")
          .doc(uid)
          .get()
          .then((document) async => {
        if (document.exists) {await document.reference.delete()}
      });

      await _activity
          .doc(_userAuth.user.uid)
          .collection('user')
          .doc(uid)
          .get()
          .then((document) async => {
        if (document.exists) {await document.reference.delete()}
      });

      return Future.value(false);
    } catch (e) {
      print(e.toString());
      return Future.value(true);
    }
  }

  Stream<DocumentSnapshot> getUserInfoStream({String uid}) {
    return _users.doc(uid).snapshots();
  }

  Future<DocumentSnapshot> getUserInfoFuture({String uid}) {
    return _users.doc(uid).get();
  }

  getUserInfo({String uid}) {
    try {
      return _users.doc(uid).get();
    } catch (e) {
      print("getUserInfo" + e.toString());
      return null;
    }
  }

  Stream getChats() {
    return _chatUIDs.doc(_userAuth.user.uid).collection("chatUID").orderBy("timestamp",descending: true).snapshots();
  }

  Future checkChatExists({String targetUID}) async {
    try {
      String chatID;
      String currentUID = _userAuth.user.uid;
      if (currentUID.compareTo(targetUID) == -1) {
        chatID = currentUID + targetUID;
      } else {
        chatID = targetUID + currentUID;
      }
      bool result;
      await _chatUIDs.doc(currentUID).collection("chatUID").doc(chatID).get().then((document) {
        if (document.exists) {
          result = document.data().keys.contains(chatID);
        } else {
          result = false;
        }
      });
      return result;
    } catch (e) {
      print("checkChats : " + e.toString());
      return null;
    }
  }

  Future addChatSender({String targetUID}) async {
    try {
      String chatID;
      String currentUID = _userAuth.user.uid;
      if (currentUID.compareTo(targetUID) == -1) {
        chatID = currentUID + targetUID;
      } else {
        chatID = targetUID + currentUID;
      }
      await _chatUIDs
          .doc(currentUID).collection("chatUID").doc(chatID)
          .set({"uid": targetUID,"timestamp":DateTime.now()}, SetOptions(merge: true));
    } catch (e) {
      print("getChats : " + e.toString());
      return null;
    }
  }

  Future addChatReceiver({String targetUID}) async {
    try {
      String chatID;
      String currentUID = _userAuth.user.uid;
      if (currentUID.compareTo(targetUID) == -1) {
        chatID = currentUID + targetUID;
      } else {
        chatID = targetUID + currentUID;
      }
      await _chatUIDs
          .doc(targetUID).collection("chatUID").doc(chatID)
          .set({"uid": currentUID,"timestamp":DateTime.now()}, SetOptions(merge: true));
    } catch (e) {
      print("getChats : " + e.toString());
      return null;
    }
  }

  Stream getChatDetails({String targetUID}) {
    String chatID;
    String currentUID = _userAuth.user.uid;
    if (currentUID.compareTo(targetUID) == -1) {
      chatID = currentUID + targetUID;
    } else {
      chatID = targetUID + currentUID;
    }
    return _allChats
        .doc(chatID)
        .collection(chatID)
        .orderBy("timestamp", descending: true)
        .limit(50)
        .snapshots();
  }

  Stream getLastMessage({String targetUID}) {
    String chatID;
    String currentUID = _userAuth.user.uid;
    if (currentUID.compareTo(targetUID) == -1) {
      chatID = currentUID + targetUID;
    } else {
      chatID = targetUID + currentUID;
    }
    return _allChats
        .doc(chatID)
        .collection(chatID)
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots();
  }

  Future sendMessage(
      {String targetUID, String message, String type = "text"}) async {
    try {
      String chatID;
      String currentUID = _userAuth.user.uid;
      if (currentUID.compareTo(targetUID) == -1) {
        chatID = currentUID + targetUID;
      } else {
        chatID = targetUID + currentUID;
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      await _allChats
          .doc(chatID)
          .collection(chatID)
          .doc(timestamp.toString())
          .set(
        {
          "reciever": targetUID,
          "message": message,
          "type": type,
          "timestamp": timestamp
        },
      );
    } catch (e) {
      return null;
    }
  }

  Stream getActivityFeed({String uid}) {
    try {
      return _notificationCenter
          .doc(uid)
          .collection("notifs")
          .orderBy("timestamp", descending: true)
          .limit(25)
          .snapshots();
    } catch (e) {
      print(e.toString());
    }
  }
}
