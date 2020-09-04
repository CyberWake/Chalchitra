import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/notifier/auth_notifier.dart';

//  Required attributes

UserDataModel currentuserModel;

AuthNotifier authNotifier;

final ref = Firestore.instance.collection('WowUsers');

//  Creating User Record in FireStore
Future<void> createUserRecord() async {
  // create a document for the user with the uid(user id)

  DocumentSnapshot userRecord = await ref.document(authNotifier.user.uid).get();

  if (authNotifier.user != null) {
    if (userRecord.data == null) {
      // no user record exists, time to create

      ref.document(authNotifier.user.uid).setData({
        "id": authNotifier.user.uid,
        "displayName": authNotifier.user.displayName,
        "email": authNotifier.user.email,
        "photoUrl": authNotifier.user.photoUrl,
        "username": "",
        "bio": "",
        "followers": {},
        "following": {}
      });

      userRecord = await ref.document(authNotifier.user.uid).get();
    }

    currentuserModel = UserDataModel.fromDocument(userRecord);
  }
}
