import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/shared/formFormatting.dart';
import 'package:wowtalent/staticData/countryList.dart';
import 'package:wowtalent/widgets/bouncingButton.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
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
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  // Global key for snack bar

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  UserDataModel _userDataModel;
  UserInfoStore _userInfoStore = UserInfoStore();
  // Some Attributes for text field
  DateTime pickedDate;
  bool loading = false;
  UserDataModel user = UserDataModel();
  bool _usernameValid = true;
  bool validUsername;
  bool validCountry;
  bool _nameValid = true;
  bool _updateButton = true;
  int _selectedGender;
  Size _size;
  String gender;
  String _dob;
  String url =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";
  String onUrlNull =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";
  String selectedCountry = "";
  String fileName = '';
  String currentUserName;
  File file;

  final ref = FirebaseFirestore.instance.collection('WowUsers');

  displayUserInformation() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print("Username Index: ${pref.getString('id')}");
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot = await ref.doc(widget.uid).get();
    user = UserDataModel.fromDocument(documentSnapshot);
    url = user.photoUrl ?? "";
    currentUserName = user.username;
    usernameController.text = user.username;
    nameController.text = user.displayName;
    bioController.text = user.bio == "Hello World!" ? "" : user.bio;
    countryController.text = user.country;
    _dobController.text = user.dob;
    genderController.text = user.gender;
    print(countryController.text);
    _dob = user.dob;
    gender = user.gender;
    switch (genderController.text) {
      case "Male":
        _selectedGender = 0;
        break;
      case "FeMale":
        _selectedGender = 1;
        break;
      case "Others":
        _selectedGender = 2;
        break;
      case "Prefer not to say":
        _selectedGender = 3;
        break;
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
      validUsername =
          await _userInfoStore.isUsernameNew(username: usernameController.text);
      print(validUsername);
    } else {
      validUsername = true;
    }
    validCountry = (countries.contains(countryController.text));

    if (_usernameValid && _nameValid && validUsername && validCountry) {
      setState(() {
        loading = true;
      });

      ref.doc(widget.uid).update({
        "username": usernameController.text,
        "displayName": nameController.text,
        "bio": bioController.text,
        "dob": _dobController.text,
        "gender": genderController.text,
        "country": countryController.text,
        "photoUrl": url,
      });

      setState(() {
        loading = false;
        _updateButton = !_updateButton;
      });

      // showing a alert to the user
      SnackBar successSnackBar = SnackBar(
        content: Text('Profile Saved!!'),
        duration: Duration(milliseconds: 1000),
      );
      cupertinoSnackbar(context, "Profile Updated");
          // : _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
      print('updated successfully');
      UserDataModel userData = UserDataModel(
        id: user.id,
        displayName: nameController.text,
        username: usernameController.text,
        bio: bioController.text,
        dob: _dobController.text,
        country: countryController.text,
        photoUrl: url,
        gender: genderController.text,
        followers: user.followers,
        following: user.following,
        videoCount: user.videoCount,
      );
      Provider.of<CurrentUser>(context, listen: false)
          .updateCurrentUser(userData);
      await Future.delayed(Duration(milliseconds: 1500));
      int count = 0;
      Navigator.popUntil(context, (route) => count++ == 2);
          // : Navigator.pop(context);
    } else if (!validUsername) {
      SnackBar successSnackBar = SnackBar(
        content: Text('Username Already Taken!!'),
      );

      cupertinoSnackbar(context, "Username Already Taken");
          // : _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    } else if (!validCountry) {
      SnackBar successSnackBar = SnackBar(
        content: Text('Enter a valid country name'),
        duration: Duration(milliseconds: 1000),
      );
      cupertinoSnackbar(context, "Enter a valid country name");
          // : _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  void initState() {
    super.initState();
    displayUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Container(
        color: AppTheme.primaryColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Material(
                  color: AppTheme.primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppTheme.pureWhiteColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppTheme.pureWhiteColor,
                          ),
                          onPressed: () {})
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          url == "" ? NetworkImage(onUrlNull) : NetworkImage(url),
                      radius: 50,
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 70,
                      child: Container(
                        width: 30,
                        height: 30,
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          color: AppTheme.pureWhiteColor,
                          elevation: 10,
                          type: MaterialType.circle,
                          child: IconButton(
                            icon: Icon(Icons.add),
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              file =
                                  await FilePicker.getFile(type: FileType.image);
                              fileName = path.basename(file.path);
                              setState(() {
                                fileName = path.basename(file.path);
                              });
                              StorageReference storageReference = FirebaseStorage
                                  .instance
                                  .ref()
                                  .child("images/" + user.id);
                              StorageUploadTask uploadTask =
                                  storageReference.putFile(file);

                              final StorageTaskSnapshot downloadUrl =
                                  (await uploadTask.onComplete);
                              url = (await downloadUrl.ref.getDownloadURL());
                              cupertinoSnackbar(
                                  context, "Profile Picture Updated");
                              setState(() {
                                print("setstate called");
                              });
                              await ref.doc(widget.uid).update({
                                "photoUrl": url,
                              });
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Form(
                    child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    nameField(),
                    usernameField(),
                    bioField(),
                    dobField(),
                    Row(
                      children: [
                        Flexible(child: genderField()),
                        Flexible(
                          child: countryField(),
                        )
                      ],
                    )
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    width: _size.width,
                    height: _size.height * 0.06,
                    child: RaisedButton(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                      onPressed: () {
                        updateUserProfile();
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                            color: AppTheme.pureWhiteColor, fontSize: 20),
                      ),
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  nameField() {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextFormField(
          controller: nameController,
          style: TextStyle(color: AppTheme.pureWhiteColor),
          decoration: editFormFieldFormatting(hint: "Name", label: "Name"),
        ),
      ),
    );
  }

  usernameField() {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextFormField(
          controller: usernameController,
          style: TextStyle(color: AppTheme.pureWhiteColor),
          decoration:
              editFormFieldFormatting(hint: "Username", label: "Username"),
        ),
      ),
    );
  }

  bioField() {
    return Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextFormField(
            controller: bioController,
            style: TextStyle(color: AppTheme.pureWhiteColor),
            decoration: editFormFieldFormatting(hint: "Bio", label: "Bio"),
          ),
        ));
  }

  dobField() {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: InkWell(
          onTap: () {
            Platform.isIOS
                ? showCupertinoModalPopup(
                    context: context,
                    builder: (_) {
                      return Container(
                        height: _size.height * 0.3,
                        color: CupertinoColors.lightBackgroundGray,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                      child: Text("Done",style: TextStyle(fontSize: 20,color: AppTheme.secondaryColor),),
                                    ),
                                    onTap: ()=>Navigator.pop(context),
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                backgroundColor: CupertinoColors.lightBackgroundGray,
                                mode: CupertinoDatePickerMode.date,
                                onDateTimeChanged: (val) {
                                  setState(() {
                                    pickedDate = val;
                                    _dobController.text = pickedDate.day.toString() +
                                        "-" +
                                        pickedDate.month.toString() +
                                        "-" +
                                        pickedDate.year.toString();
                                  });
                                },
                                initialDateTime: DateTime.now(),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                : _selectDate(context);
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: _dobController,
              // initialValue: _dob == null ? "Please Provide the Date of Birth": _dob,
              style: TextStyle(color: AppTheme.pureWhiteColor),
              decoration: editFormFieldFormatting(
                  hint: "Date of Birth", label: "Date of Birth"),
            ),
          ),
        ),
      ),
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
        _dobController.text = pickedDate.day.toString() +
            "-" +
            pickedDate.month.toString() +
            "-" +
            pickedDate.year.toString();
      });
  }

  genderField() {
    List<String> _genderList = [
      "Male",
      "Female",
      "Others",
      "Prefer not to say"
    ];
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: InkWell(
          onTap: () => showCupertinoModalPopup(
              context: context,
              builder: (_) {
                return Container(
                  height: _size.height * 0.3,
                  color: CupertinoColors.lightBackgroundGray,
                  child: Column(
                    children: [
                      Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                      child: Text("Done",style: TextStyle(fontSize: 20,color: AppTheme.secondaryColor),),
                                    ),
                                    onTap: ()=>Navigator.pop(context),
                                  ),
                                )
                              ],
                            ),
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: CupertinoColors.lightBackgroundGray,
                          itemExtent: 45,
                          children: [
                            Center(child: Text("Male")),
                            Center(child: Text("Female")),
                            Center(child: Text("Others")),
                            Center(child: Text("Prefer not to say")),
                          ],
                          onSelectedItemChanged: (v) {
                            setState(() {
                              genderController.text = _genderList[v];
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
          child: IgnorePointer(
            child: TextFormField(
              controller: genderController,
              style: TextStyle(color: AppTheme.pureWhiteColor),
              decoration:
                  editFormFieldFormatting(hint: "Gender", label: "Gender"),
            ),
          ),
        ),
      ),
    );
  }

  countryField() {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: InkWell(
          onTap: () => showCupertinoModalPopup(
              context: context,
              builder: (_) {
                return Container(
                  color: CupertinoColors.lightBackgroundGray,
                    height: _size.height * 0.3,
                    child: Column(
                      children: [
                        Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                      child: Text("Done",style: TextStyle(fontSize: 20,color: AppTheme.secondaryColor),),
                                    ),
                                    onTap: ()=>Navigator.pop(context),
                                  ),
                                )
                              ],
                            ),
                        Expanded(
                          child: CupertinoPicker(
                            backgroundColor: CupertinoColors.lightBackgroundGray,
                            itemExtent: 45,
                            onSelectedItemChanged: (val) {
                              setState(() {
                                countryController.text = countries[val];
                              });
                            },
                            children:
                                List<Widget>.generate(countries.length, (index) {
                              return Center(
                                child: Text(countries[index]),
                              );
                            }),
                          ),
                        ),
                      ],
                    ));
              }),
          child: IgnorePointer(
            child: TextFormField(
              controller: countryController,
              style: TextStyle(color: AppTheme.pureWhiteColor),
              decoration:
                  editFormFieldFormatting(hint: "Country", label: "Country"),
            ),
          ),
        ),
      ),
    );
  }
}
