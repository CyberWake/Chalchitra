import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';

class CurrentUser with ChangeNotifier {
  UserDataModel currentUserData;
  updateCurrentUser(UserDataModel userData) {
    currentUserData = userData;
    print("User Logged in: ${currentUserData.id}");
    notifyListeners();
  }
}
