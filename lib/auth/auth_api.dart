import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wowtalent/database/firestore_api.dart';
import 'package:wowtalent/model/user.dart';
import '../model/user.dart';

class UserAuth{
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('WowUsers');
  static UserDataModel currentUserModel;

  Stream<User> get account{
    return _auth.authStateChanges();
  }

  User get user{
    return _auth.currentUser;
  }

  Future signInWithEmailAndPassword({String email, String password}) async{
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot userRecord =
      await _usersCollection.doc(userCredential.user.uid).get();

      if(!userRecord.exists){
        await UserInfoStore().createUserRecord().then((value) async{
          if(value){
            userRecord =
            await _usersCollection.doc(userCredential.user.uid).get();
            currentUserModel = UserDataModel.fromDocument(userRecord);
          }
        });
      }

      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      }
    }catch(e){
      print("error : " + e.toString());
      return null;
    }
  }

  Future registerUserWithEmail({String email, String password, String username}) async{
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userRecord =
      await _usersCollection.doc(userCredential.user.uid).get();
      if(!userRecord.exists){
        await UserInfoStore().createUserRecord(
          username: username
        ).then((value) async{
         if(value){
           userRecord =
           await _usersCollection.doc(userCredential.user.uid).get();
           currentUserModel = UserDataModel.fromDocument(userRecord);
         }
        });
      }
      return "success";
    } on FirebaseAuthException catch (e) {
      if(e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for this email.';
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  Future<bool> signInWithGoogle() async {
    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      DocumentSnapshot userRecord =
      await _usersCollection.doc(userCredential.user.uid).get();

      if(!userRecord.exists){
        await UserInfoStore().createUserRecord().then((value) async{
          if(value){
            userRecord =
            await _usersCollection.doc(userCredential.user.uid).get();
            currentUserModel = UserDataModel.fromDocument(userRecord);
          }
        });
      }
      return true;
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }

  Future<bool> signOut() async{
    try{
      await _auth.signOut();
      return true;
    }catch(e){
      print(e.toString());
      return false;
    }
  }
}