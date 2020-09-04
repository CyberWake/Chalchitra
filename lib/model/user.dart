import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataModel {
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

  UserDataModel(
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

  factory UserDataModel.fromDocument(DocumentSnapshot document) {
    return UserDataModel(
        displayName: document.data()['displayName'],
        email: document.data()['email'],
        id: document.id,
        photoUrl: document.data()['photoUrl'],
        bio: document.data()['bio'],
        username: document.data()['username'],
        age: document.data()['age'],
        gender: document.data()['gender'],
        followers: document.data()['followers'],
        following: document.data()['following']);
  }
}
