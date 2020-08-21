import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/auth_api.dart'; //for currentuser & google signin instance
import 'package:wowtalent/model/user.dart';
import 'package:wowtalent/notifier/auth_notifier.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  changeProfilePhoto(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Changing your profile photo has not been implemented yet'),
              ],
            ),
          ),
        );
      },
    );
  }

  // applyChanges() {
  //   Firestore.instance
  //       .collection('WowUsers')
  //       .document(currentUserModel.id)
  //       .updateData({
  //     "displayName": nameController.text,
  //     "bio": bioController.text,
  //   });
  // }

  // Column buildTextField({String name, TextEditingController controller}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Padding(
  //         padding: const EdgeInsets.only(top: 12.0),
  //         child: Text(
  //           name,
  //           style: TextStyle(color: Colors.grey),
  //         ),
  //       ),
  //       TextField(
  //         controller: controller,
  //         decoration: InputDecoration(
  //           hintText: name,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Column createUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            'Username',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.black),
          controller: usernameController,
          decoration: InputDecoration(
              hintText: 'Write your username here...',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  Column createProfileNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            'Profile name',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.black),
          controller: nameController,
          decoration: InputDecoration(
              hintText: 'Write your name here...',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  Column createBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.black),
          controller: bioController,
          decoration: InputDecoration(
              hintText: 'Write your bio here...',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  Column createAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            'Age',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.black),
          controller: ageController,
          decoration: InputDecoration(
              hintText: 'Write your age here...',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  Column createGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            'Gender',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextFormField(
          style: TextStyle(color: Colors.black),
          controller: ageController,
          decoration: InputDecoration(
              hintText: 'Write your male here...',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child: Container(
              child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage("https://via.placeholder.com/150"),
                  radius: 50.0,
                ),
              ),
              FlatButton(
                  onPressed: () {
                    changeProfilePhoto(context);
                  },
                  child: Text(
                    "Change Photo",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Column(children: <Widget>[
                  createUsernameField(),
                  createProfileNameField(),
                  createBioField(),
                  createAgeField(),
                  createGenderField()
                ]),
              )
            ],
          )),
        )
      ]),
    );
  }
}
