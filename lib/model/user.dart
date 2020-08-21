import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String displayName;
  String email;
  String password;
  String id;
  String photoUrl;
  String username;
  String bio;
  String age;
  String gender;
  Map followers;
  Map following;

  User(
      {this.displayName,
      this.email,
      this.password,
      this.id,
      this.photoUrl,
      this.bio,
      this.username,
      this.age,
      this.gender,
      this.followers,
      this.following});

  factory User.fromDocument(DocumentSnapshot document) {
    return User(
        displayName: document['displayName'],
        email: document['email'],
        id: document.documentID,
        photoUrl: document['photoUrl'],
        bio: document['bio'],
        username: document['username'],
        age: document['age'],
        gender: document['gender'],
        followers: document['followers'],
        following: document['following']);
  }
}
