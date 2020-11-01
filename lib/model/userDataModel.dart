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
  String dob;
  String country;
  String gender;
  bool private;
  int followers;
  int following;
  int videoCount;
  String fcmToken;

  UserDataModel(
      {this.displayName,
      this.email,
      this.password,
      this.id,
      this.photoUrl,
      this.bio,
      this.username,
      this.age,
      this.dob,
      this.country,
      this.gender,
      this.private = false,
      this.followers,
      this.following,
      this.videoCount,
      this.fcmToken
      });

  factory UserDataModel.fromDocument(DocumentSnapshot document) {
    return UserDataModel(
        displayName: document.data()['displayName'],
        email: document.data()['email'],
        id: document.id,
        photoUrl: document.data()['photoUrl'],
        bio: document.data()['bio'],
        username: document.data()['username'],
        age: document.data()['age'],
        dob: document.data()['dob'],
        country: document.data()['country'],
        gender: document.data()['gender'],
        private: document.data()['private'],
        followers: document.data()['followers'],
        following: document.data()['following'],
        videoCount: document.data()['videoCount'],
        fcmToken: document.data()['fcmToken']);
  }
}
