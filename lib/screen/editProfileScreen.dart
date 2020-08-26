import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wowtalent/model/user.dart';

class EditProfilePage extends StatefulWidget {
  // User id required to open this screen

  final uid;
  EditProfilePage({this.uid});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Text Controller

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  // Global key for snack bar

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();

  // Some Attributes for text field

  bool loading = false;
  User user;
  bool _usernameValid = true;
  bool _nameValid = true;

  // Calling Cloud Firestore collection

  final ref = Firestore.instance.collection('WowUsers');

  // Recovering pervious state

  void initState() {
    super.initState();

    displayUserInformation();
  }

  displayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await ref.document(widget.uid).get();
    user = User.fromDocument(documentSnapshot);

    usernameController.text = user.username;
    nameController.text = user.displayName;
    bioController.text = user.bio;
    ageController.text = user.age;

    setState(() {
      loading = false;
    });
  }

  // Updating user profile

  updateUserProfile() {
    // Validate text field

    setState(() {
      usernameController.text.trim().length < 3 ||
              usernameController.text.isEmpty
          ? _usernameValid = false
          : _usernameValid = true;

      nameController.text.isEmpty ? _nameValid = false : _nameValid = true;
    });

    if (_usernameValid && _nameValid) {
      setState(() {
        loading = true;
      });

      ref.document(widget.uid).updateData({
        "username": usernameController.text,
        "displayName": nameController.text,
        "bio": bioController.text,
        "age": ageController.text,
        "gender": genderController.text
      });

      setState(() {
        loading = false;
      });

      // showing a alert to the user

      SnackBar successSnackBar = SnackBar(
        content: Text('Profile has update successfully!!'),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
      print('updated successfully');
    }
  }

  // Creating username field

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
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _usernameValid ? null : 'Username is too sort!'),
        )
      ],
    );
  }

  // Creating profilename field

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
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _nameValid ? null : 'Profile name cannot be empty!'),
        )
      ],
    );
  }

  // Creating bio field

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

  // Creating age field

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

  //Gender

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
          controller: genderController,
          decoration: InputDecoration(
              hintText: 'Write your gender here...',
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

  // Main code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
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
      body: loading
          ? LinearProgressIndicator()
          : ListView(children: <Widget>[
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
                          Navigator.pop(context);
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
                        // createGenderField()
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 50, right: 50),
                      child: RaisedButton(
                          child: Text(
                            'Update',
                            style:
                                TextStyle(color: Colors.black45, fontSize: 16),
                          ),
                          onPressed: updateUserProfile),
                    )
                  ],
                )),
              )
            ]),
    );
  }
}
