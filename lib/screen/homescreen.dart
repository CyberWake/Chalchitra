import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/auth_api.dart';

import 'package:wowtalent/notifier/auth_notifier.dart';

class HomeScreen extends StatelessWidget {
  // const Home_Screen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(authNotifier.user != null
              ? authNotifier.user.displayName
              : "WowTalent"),
          backgroundColor: Colors.teal,
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () => signOut(authNotifier),
            )
          ]),
    );
  }
}
