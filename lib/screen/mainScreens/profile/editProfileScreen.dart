import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/shared/formFormatting.dart';
import 'package:wowtalent/widgets/dropdownField.dart';
import 'package:wowtalent/staticData/countryList.dart';


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
  final TextEditingController countryController = TextEditingController();

  // Global key for snack bar

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  UserDataModel _userDataModel = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  // Some Attributes for text field
  DateTime pickedDate;
  bool loading = false;
  UserDataModel user;
  bool _usernameValid = true;
  bool validUsername;
  bool _nameValid = true;
  bool _updateButton = true;
  int _selectedGender;
  Size _size;
  String gender;
  String _dob;
  String url = "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";
  String onUrlNull = "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";
  String selectedCountry = "";
  String fileName = '';
  String currentUserName;
  File file;

  // Calling Cloud Firestore collection

  final ref = FirebaseFirestore.instance.collection('WowUsers');

  // Recovering pervious state

  void initState() {
    super.initState();
    displayUserInformation();
  }

  // Main code

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldGlobalKey,
      body: Container(
        color: Colors.orange,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: _size.height * 0.1
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0.0, -10.0), //(x,y)
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: loading
                  ? LinearProgressIndicator()
                  : ListView(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                            child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Column(children: <Widget>[
                                getFieldContainer(
                                    [
                                      createProfileNameField(),
                                      createUsernameField(),
                                    ]
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                getFieldContainer(
                                    [
                                      createBioField(),
                                      createGenderField(),
                                      createCountryField(),
                                      createDOBField(),
                                    ]
                                ),
                                // createGenderField()
                              ]),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: _updateButton
                                  ? updateUserProfile
                                  :()=>Navigator.pop(context),
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.orange,
                                ),
                                child: Center(
                                  child: _updateButton?
                                  Text("Update", style: TextStyle(color: Colors
                                      .white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      fontSize: 17),):
                                  Text("Back", style: TextStyle(color: Colors
                                      .white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      fontSize: 17),)
                                ),
                              ),
                            ),
                          ],
                        )),
                      )
                    ]),
            ),
            Container(
              margin: EdgeInsets.only(
                top: _size.height * 0.05,
                left: _size.width * 0.5 - 50,
              ),
              child: CircleAvatar(
                backgroundImage:
                url == onUrlNull?NetworkImage(url):NetworkImage(onUrlNull),
                radius: 50.0,
              ),
            ),
            InkWell(
              onTap: () async {
                file = await FilePicker.getFile(type: FileType.image);
                fileName = path.basename(file.path);
                setState(() {
                  fileName = path.basename(file.path);
                });
                StorageReference storageReference = FirebaseStorage
                    .instance
                    .ref()
                    .child("images/"+user.id);
                StorageUploadTask uploadTask =
                storageReference.putFile(file);

                final StorageTaskSnapshot downloadUrl =
                (await uploadTask.onComplete);
                url = (await downloadUrl.ref.getDownloadURL());
                await ref.doc(widget.uid).update({"photoUrl": url,});
                setState((){
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(50)
                ),
                padding: EdgeInsets.all(2.5),
                margin: EdgeInsets.only(
                  top: _size.height * 0.05,
                  left: _size.width * 0.57,
                ),
                child: Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  getFieldContainer(List<Widget> fields){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.orange.withOpacity(0.15),
          blurRadius: 20,
          offset: Offset(0, 10),
        )
        ],
      ),
      child: Column(
        children: fields,
      ),
    );
  }

  displayUserInformation() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot = await ref.doc(widget.uid).get();
    user = UserDataModel.fromDocument(documentSnapshot);
    url = user.photoUrl;
    currentUserName = user.username;
    usernameController.text = user.username;
    nameController.text = user.displayName;
    bioController.text = user.bio;
    countryController.text = user.country;
    print(countryController.text);
    _dob = user.dob;
    gender = user.gender;
    switch(gender){
      case "Male": _selectedGender = 0;break;
      case "FeMale": _selectedGender = 1;break;
      case "Others": _selectedGender = 2;break;
      case "Prefer not to say": _selectedGender = 3;break;
    }
    setState(() {
      loading = false;
    });
  }

  // Updating user profile

  updateUserProfile() async {
    // Validate text field

    setState(() {
      usernameController.text.trim().length < 3 ||
          usernameController.text.isEmpty
          ? _usernameValid = false
          : _usernameValid = true;

      nameController.text.isEmpty ? _nameValid = false : _nameValid = true;
    });
    if (currentUserName != usernameController.text) {
      validUsername = await _userInfoStore.isUsernameNew(
          username: usernameController.text);
      print(validUsername);
    }else{
      validUsername = true;
    }

    if (_usernameValid && _nameValid && validUsername) {
      setState(() {
        loading = true;
      });

      ref.doc(widget.uid).update({
        "username": usernameController.text,
        "displayName": nameController.text,
        "bio": bioController.text,
        "dob": _dob,
        "gender": gender,
        "country": countryController.text,
        "photoUrl": url,
      });

      setState(() {
        loading = false;
        _updateButton = !_updateButton;
      });

      // showing a alert to the user
      SnackBar successSnackBar = SnackBar(
        content: Text('Profile has update successfully!!'),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
      print('updated successfully');
    }
    else if(!validUsername){
      SnackBar successSnackBar = SnackBar(
        content: Text('Username Already Taken!!'),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  // Creating username field
  createUsernameField() {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey[200]))
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: usernameController,
        decoration: authInputFormatting.copyWith(
            hintText: "Username",
            border: OutlineInputBorder(),
            labelText: 'Username',
            errorText: _usernameValid ? null : 'Username is too sort!'
        ),
      ),
    );
  }
  // Creating profile name field
  createProfileNameField() {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey[200]))
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: nameController,
        decoration: authInputFormatting.copyWith(
            hintText: "Profile Name",
            border: OutlineInputBorder(),
            labelText: 'Profile Name',
            errorText: _nameValid ? null : 'Profile name cannot be empty!'
        ),
      ),
    );
  }
  // Creating bio field
  createBioField() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: bioController,
        decoration:  authInputFormatting.copyWith(
            hintText: "Your Bio",
          border: OutlineInputBorder(),
          labelText: 'Your Bio',
        ),
      ),
    );
  }
  //Gender
  createGenderField() {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          padding: const EdgeInsets.only(left:5, top:5, bottom:5),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[600]),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 13.0,right: 15),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                  value: _selectedGender,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      child: Text("Male"),
                      value: 0,
                    ),
                    DropdownMenuItem(
                      child: Text("Female"),
                      value: 1,
                    ),
                    DropdownMenuItem(
                        child: Text("Others"),
                        value: 2
                    ),
                    DropdownMenuItem(
                        child: Text("Prefer not to say"),
                        value: 3
                    ),
                  ],
                  onChanged: (value) {
                    _selectedGender = value;
                    switch(_selectedGender){
                      case 0: gender = "Male";break;
                      case 1: gender = "Female";break;
                      case 2: gender = "Others";break;
                      case 3: gender = "Prefer not to say";break;
                    }
                    setState(() {

                    });
                  }),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(left: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3.0),
              child: Text(
                'Gender',
                style: TextStyle(color: Colors.grey[600],fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
  //Country
  createCountryField() {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[700],width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropDownField(
            hintText: "Country",
            controller: countryController,
            value: countryController.text,
            items: countries,
            onValueChanged: (value){
              FocusScope.of(context).unfocus();
              setState(() {
                selectedCountry = value;
                countryController.text = value;
              });
            },
            setter: (value){
              FocusScope.of(context).unfocus();
              print(countryController.text);
              countryController.text = value;
            },
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(left: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3.0),
              child: Text(
                'Country',
                style: TextStyle(color: Colors.grey[600],fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // Creating date of birth field
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());
    if (picked != null)
      setState(() {
        pickedDate = picked;
        _dob = pickedDate.day.toString()+"-"+pickedDate.month.toString()+"-"+pickedDate.year.toString();
      });
  }
  createDOBField() {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          height: _size.height * 0.075,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[700],width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            onTap:() => _selectDate(context),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(_dob == null?"Please Provide your Date of Birth":_dob,
                  style: TextStyle(fontSize: 16,color: Colors.black),),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(left: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3.0),
              child: Text(
                'Date of Birth',
                style: TextStyle(color: Colors.grey[600],fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
