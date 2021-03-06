import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Chalchitra/imports.dart';

class UserAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('WowUsers');
  static UserDataModel currentUserModel;
  UserCredential userCredential;

  Stream<User> get account {
    return _auth.authStateChanges();
  }

  User get user {
    return _auth.currentUser;
  }

  addPreference(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('uid', id);
  }

  Future signInWithEmailAndPassword(
      {String email, String password, BuildContext context}) async {
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user.emailVerified) {
        DocumentSnapshot userSnapshot =
            await _usersCollection.doc(userCredential.user.uid).get();
        if (userSnapshot.exists) {
          UserDataModel user = UserDataModel.fromDocument(userSnapshot);
          Provider.of<CurrentUser>(context, listen: false)
              .updateCurrentUser(user);
          addPreference(user.id);
          return "success";
        } else {
          return "No user found for this email.";
        }
      } else {
        return "User Not Verified";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      }
    } catch (e) {
      print("error : " + e.toString());
      return null;
    }
  }

  Future registerUserWithEmail(
      {String email,
      String password,
      String username,
      BuildContext context}) async {
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user.sendEmailVerification();
      DocumentSnapshot userRecord =
          await _usersCollection.doc(userCredential.user.uid).get();
      if (!userRecord.exists) {
        await UserInfoStore()
            .createUserRecord(username: username)
            .then((value) async {
          if (value) {
            addPreference(user.uid);
            print("user created");
          }
        });
      }
      await _auth.signOut();
      userCredential = null;
      return "Check mailbox and verify your account to login";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for this email.';
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithFacebook(BuildContext context) async {
    AccessToken userToken;
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      userToken = result.accessToken;

      print("running facebook auth");
      switch (result.status) {
        case FacebookAuthLoginResponse.ok:
          print("checking auth status");
          final FacebookAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(userToken.token);

          userCredential =
              await _auth.signInWithCredential(facebookAuthCredential);
          DocumentSnapshot userRecord =
              await _usersCollection.doc(userCredential.user.uid).get();
          if (!userRecord.exists) {
            return "newUser";
          }
          UserDataModel user = UserDataModel.fromDocument(userRecord);
          Provider.of<CurrentUser>(context, listen: false)
              .updateCurrentUser(user);
          addPreference(user.id);
          return true;
          break;
        case FacebookAuthLoginResponse.cancelled:
          print("Cancelled by user");
          return false;
      }
    } catch (e) {
      await FacebookAuth.instance.logOut();
      print("facebook login error: " + e.toString());
      return false;
    }
  }

  Future signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
      DocumentSnapshot userRecord =
          await _usersCollection.doc(userCredential.user.uid).get();
      if (!userRecord.exists) {
        return "newUser";
      }
      UserDataModel user = UserDataModel.fromDocument(userRecord);
      Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
      addPreference(user.id);
      return true;
    } catch (e) {
      await GoogleSignIn().signOut();
      print("google login error: " + e.toString());
      return false;
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset link sent";
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<bool> signOut() async {
    try {
      await FacebookAuth.instance.logOut();
      await GoogleSignIn().signOut();
      await _auth.signOut();
      userCredential = null;
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
