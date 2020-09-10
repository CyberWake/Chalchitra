import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wowtalent/model/user.dart';
import '../auth/auth_api.dart';

class UserInfoStore{
  UserDataModel _currentUserModel;
  static final CollectionReference _users = FirebaseFirestore.instance.collection('WowUsers');
  final _followers = FirebaseFirestore.instance.collection('followers');
  final _followings = FirebaseFirestore.instance.collection('following');
  final _activity = FirebaseFirestore.instance.collection('activity feed');
  final _chatUIDs = FirebaseFirestore.instance.collection('chatUIDs');
  final _allChats = FirebaseFirestore.instance.collection('allChats');


  static final UserAuth _userAuth = UserAuth();

  Future<bool> createUserRecord({String username = ""}) async {
    try{
      DocumentSnapshot userRecord = await _users.doc(_userAuth.user.uid).get();
      if (_userAuth.user != null) {
        if (!userRecord.exists) {
          Map<String, dynamic> userData = {
            "id": _userAuth.user.uid,
            "displayName": _userAuth.user.displayName,
            "email": _userAuth.user.email,
            "photoUrl": _userAuth.user.photoURL,
            "username": username,
            "bio": "Welcome To My Profile",
          };
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
    try{
      DocumentSnapshot documentSnapshot =
      await _followings
          .doc(uid)
          .collection('usersFollowers')
          .doc(_userAuth.user.uid).get();
      return documentSnapshot.exists;
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  Future<bool> followUser({String uid}) async{
    try{
      await _followers
          .doc(uid)
          .collection('userFollowers')
          .doc(_userAuth.user.uid)
          .set({});

      await _followings
          .doc(_userAuth.user.uid)
          .collection('userFollowing')
          .doc(uid)
          .set({});

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
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  Future<bool> unFollowUser({String uid}) async {
   try{
     await _followers
         .doc(uid)
         .collection("userFollowers")
         .doc(_userAuth.user.uid)
         .get()
         .then((document) async => {
           if(document.exists){
            await document.reference.delete()
           }
     });

     await _followings
         .doc(_userAuth.user.uid)
         .collection("userFollowing")
         .doc(uid)
         .get()
         .then((document) async => {
       if (document.exists) {
         await document.reference.delete()}
     });

     await _activity
         .doc(uid)
         .collection('user')
         .doc(_userAuth.user.uid)
        .get()
        .then((document) async => {
    if (document.exists) {
      await document.reference.delete()}
    });

     return Future.value(false);
   }catch(e){
     print(e.toString());
     return Future.value(true);
   }
  }

  Stream<DocumentSnapshot> getUserInfoStream({String uid}){
    return _users
        .doc(uid)
        .snapshots();
  }

  Future getUserInfo({String uid}){
    try{
      return _users
          .doc(uid)
          .get();
    }catch(e){
      print("getUserInfo" + e.toString());
      return null;
    }
  }

  Stream getChats(){
    return _chatUIDs
        .doc(_userAuth.user.uid).snapshots();
  }

  Future checkChatExists({String targetUID}) async{
    try{
      String chatID;
      String currentUID = _userAuth.user.uid;
      if(currentUID.compareTo(targetUID) == -1){
        chatID = currentUID + targetUID;
      }else{
        chatID = targetUID + currentUID;
      }
      bool result;
      await _chatUIDs
          .doc(currentUID)
          .get()
          .then((document){
        if(document.exists){
           result = document.data().keys.contains(chatID);
        }else{
          result =  false;
        }
      });
      return result;
    }catch(e){
      print("checkChats : " + e.toString());
      return null;
    }
  }

  Future addChatSender({String targetUID}) async{
    try{
      String chatID;
      String currentUID = _userAuth.user.uid;
      if(currentUID.compareTo(targetUID) == -1){
        chatID = currentUID + targetUID;
      }else{
        chatID = targetUID + currentUID;
      }
      await _chatUIDs
          .doc(currentUID)
          .set({
        chatID : targetUID
      }, SetOptions(merge: true));
    }catch(e){
      print("getChats : " + e.toString());
      return null;
    }
  }

  Future addChatReceiver({String targetUID}) async{
    try{
      String chatID;
      String currentUID = _userAuth.user.uid;
      if(currentUID.compareTo(targetUID) == -1){
        chatID = currentUID + targetUID;
      }else{
        chatID = targetUID + currentUID;
      }
      await _chatUIDs
          .doc(targetUID)
          .set({
        chatID : currentUID
      }, SetOptions(merge: true));
    }catch(e){
      print("getChats : " + e.toString());
      return null;
    }
  }

  Stream getChatDetails({String targetUID}){
    String chatID;
    String currentUID = _userAuth.user.uid;
    if(currentUID.compareTo(targetUID) == -1){
      chatID = currentUID + targetUID;
    }else{
      chatID = targetUID + currentUID;
    }
    return _allChats.doc(chatID).collection(chatID)
        .orderBy("timestamp", descending: true)
        .limit(50).snapshots();
  }

  Stream getLastMessage({String targetUID}){
    String chatID;
    String currentUID = _userAuth.user.uid;
    if(currentUID.compareTo(targetUID) == -1){
      chatID = currentUID + targetUID;
    }else{
      chatID = targetUID + currentUID;
    }
    return _allChats.doc(chatID).collection(chatID)
        .orderBy("timestamp", descending: true)
        .limit(1).snapshots();
  }

  Future sendMessage({String targetUID, String message, String type = "text"}) async{
    try{
      String chatID;
      String currentUID = _userAuth.user.uid;
      if(currentUID.compareTo(targetUID) == -1){
        chatID = currentUID + targetUID;
      }else{
        chatID = targetUID + currentUID;
      }

      int timestamp =  DateTime.now().millisecondsSinceEpoch;

      await _allChats
          .doc(chatID).collection(chatID).doc(timestamp.toString())
          .set({
          "reciever" : targetUID,
          "message" : message,
          "type" : type,
          "timestamp": timestamp
      },);
    }catch(e){
      return null;
    }
  }
}