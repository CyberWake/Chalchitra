import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wowtalent/database/firesotre_api.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/notifier/auth_notifier.dart';

//  Firebase Login

logIn(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((e) => print(e.code));

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      print("Login: $firebaseUser");
      authNotifier.setUser(firebaseUser);
    }
  }
}

//Firebase Signup

signUp(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
          email: user.email, password: user.password)
      .catchError((e) => print(e.code));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.displayName;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);
      await firebaseUser.reload();

      print("Sign Up $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      authNotifier.setUser(currentUser);

      // create a document for the user with the uid(user id)

      await FirestoreDatabase(uid: authNotifier.user.uid).updateWowUser(
          authNotifier.user.email,
          authNotifier.user.photoUrl,
          authNotifier.user.displayName,
          '', {}, {});
    }
  }
}

// Firebase SignOut

signOut(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((e) => print(e.code));
  authNotifier.setUser(null);
}

// Initialize Current User

initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null) {
    print(firebaseUser);
    authNotifier.setUser(firebaseUser);
  }
}

// Google Sign In

final GoogleSignIn googleSignIn = GoogleSignIn();
final AuthNotifier authNotifier = AuthNotifier();

googlesignIn(AuthNotifier authNotifier, User user) async {
  FirebaseUser firebaseuser;
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  firebaseuser =
      (await FirebaseAuth.instance.signInWithCredential(credential)).user;
  if (firebaseuser != null) {
    authNotifier.setUser(firebaseuser);

    // create a document for the user with the uid(user id)

    await FirestoreDatabase(uid: authNotifier.user.uid).updateWowUser(
        authNotifier.user.email,
        authNotifier.user.photoUrl,
        authNotifier.user.displayName,
        '', {}, {});

    print("signed in " + firebaseuser.displayName);

    return firebaseuser;
  }
}

// Facebook Sign In

final FacebookLogin fbLogin = FacebookLogin();

facebookSignIn(
    FacebookAccessToken token, AuthNotifier authNotifier, User user) async {
  FirebaseUser firebaseuser;
  AuthCredential credential =
      FacebookAuthProvider.getCredential(accessToken: token.token);

  firebaseuser =
      (await FirebaseAuth.instance.signInWithCredential(credential)).user;

  if (firebaseuser != null) {
    authNotifier.setUser(firebaseuser);

    // create a document for the user with the uid(user id)

    await FirestoreDatabase(uid: authNotifier.user.uid).updateWowUser(
        authNotifier.user.email,
        authNotifier.user.photoUrl,
        authNotifier.user.displayName,
        '', {}, {});

    print("signedIn");
    return user;
  }
}
