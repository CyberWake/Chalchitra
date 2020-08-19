import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  //user Attributes

  final String uid;
  FirestoreDatabase({this.uid});

  String email;
  String photoUrl;
  String displayName;
  String bio;
  String followers;
  String following;

  // collections

  final CollectionReference wowCollection =
      Firestore.instance.collection('WowUsers');

  Future updateWowUser(
      email, photoUrl, displayName, bio, followers, following) async {
    return await wowCollection.document(uid).setData({
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'followers': followers,
      'following': following
    });
  }
}
