import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/provideUser.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'dart:io';

import 'package:wowtalent/screen/ios_Screens/endDrawer/draftIOS.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class Drafts extends StatefulWidget {
  @override
  _DraftsState createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  List<VideoInfo> _videos = <VideoInfo>[];
  final _formKey = GlobalKey<FormState>();
  UserAuth _userAuth = UserAuth();
  String videoHashTag = "";
  String videoName = "";
  bool _uploadingVideo = false;
  double _fontOne;
  bool _submitted = false;
  bool didUpload = false;
  int _selectedCategory = 0;
  String category = "Vocals";
  double _widthOne;
  Size _size;

  void setup() async {
    dynamic result =
        await UserVideoStore().getDraftVideos(uid: UserAuth().user.uid);
    if (result != false) {
      setState(() {
        _videos = result;
      });
      print(_videos.length);
    }
  }

  removeVideoFromDrafts(index) async {
    final videoInfo = VideoInfo(
        videoUrl: _videos[index].videoUrl,
        thumbUrl: _videos[index].thumbUrl,
        coverUrl: _videos[index].coverUrl,
        videoId: _videos[index].videoId);
    await UserVideoStore.deleteVideoDraft(videoInfo);
  }

  moveVideoToPost(int index) async {
    _uploadingVideo = true;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final videoInfo = VideoInfo(
      uploaderUid: UserAuth().user.uid,
      videoUrl: _videos[index].videoUrl,
      thumbUrl: _videos[index].thumbUrl,
      coverUrl: _videos[index].coverUrl,
      aspectRatio: _videos[index].aspectRatio,
      uploadedAt: timestamp,
      videoName: videoName,
      videoHashtag: videoHashTag,
      category: category,
      likes: 0,
      views: 0,
      rating: 0,
      comments: 0,
    );
    await UserVideoStore.saveVideo(videoInfo);
    Fluttertoast.showToast(msg: "Video Posted Successfully");
    UserDataModel user =
        await UserInfoStore().getUserInformation(uid: _userAuth.user.uid);
    Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
  }

  getCategory(String draftCategory) {
    switch (draftCategory) {
      case "Vocal":
        _selectedCategory = 0;
        break;
      case "Acting":
        _selectedCategory = 1;
        break;
      case "Instrumental":
        _selectedCategory = 2;
        break;
      case "Standup Comedy":
        _selectedCategory = 3;
        break;
      case "DJing":
        _selectedCategory = 4;
        break;
      case "Dance":
        _selectedCategory = 5;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<bool> onWillPop() {
    if (didUpload) {
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => MainScreenWrapper(index: 0)));
      return Future.value(true);
    } else {
      Navigator.pop(context);
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _fontOne = (_size.height * 0.015) / 11;
    _widthOne = _size.width * 0.0008;

    return Platform.isIOS
        ? DraftIOS(
            bodyContent: bodyContent(),
          )
        : Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.backgroundColor),
                onPressed: () {
                  if (didUpload) {
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => MainScreenWrapper(index: 0)));
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              centerTitle: true,
              title: Text('Drafts'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: bodyContent());
  }

  Widget bodyContent() {
    return _videos.length > 0
        ? Form(
            key: _formKey,
            child: Container(
              child: ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (BuildContext context, int index) {
                    getCategory(_videos[index].category);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(
                                aspectRatio: _videos[index].aspectRatio,
                                child: Image.network(
                                  _videos[index].thumbUrl,
                                  fit: BoxFit.fitWidth,
                                )),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Platform.isIOS
                                ? Material(
                                    color: AppTheme.backgroundColor,
                                    child:
                                        FormFieldFormatting.formFieldContainer(
                                      child: TextFormField(
                                        initialValue:
                                            _videos[index].videoHashtag,
                                        keyboardType: TextInputType.text,
                                        validator: (val) => val.isEmpty ||
                                                val.replaceAll(" ", '').isEmpty
                                            ? "Video Title can't be Empty"
                                            : null,
                                        onChanged: (val) {
                                          videoName = val;
                                          if (_submitted) {
                                            _formKey.currentState.validate();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter Title",
                                          hintStyle: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: _fontOne * 15,
                                          ),
                                          errorStyle: TextStyle(
                                            fontSize: _fontOne * 15,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: _fontOne * 15,
                                        ),
                                      ),
                                      leftPadding: _widthOne * 20,
                                    ))
                                : FormFieldFormatting.formFieldContainer(
                                    child: TextFormField(
                                      initialValue: _videos[index].videoHashtag,
                                      keyboardType: TextInputType.text,
                                      validator: (val) => val.isEmpty ||
                                              val.replaceAll(" ", '').isEmpty
                                          ? "Video Title can't be Empty"
                                          : null,
                                      onChanged: (val) {
                                        videoName = val;
                                        if (_submitted) {
                                          _formKey.currentState.validate();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: "Enter Title",
                                        hintStyle: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: _fontOne * 15,
                                        ),
                                        errorStyle: TextStyle(
                                          fontSize: _fontOne * 15,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: _fontOne * 15,
                                      ),
                                    ),
                                    leftPadding: _widthOne * 20,
                                  ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Platform.isIOS
                                ? Material(
                                    color: AppTheme.backgroundColor,
                                    child:
                                        FormFieldFormatting.formFieldContainer(
                                      child: TextFormField(
                                        initialValue:
                                            _videos[index].videoHashtag,
                                        keyboardType: TextInputType.text,
                                        validator: (val) => val.isEmpty ||
                                                val.replaceAll(" ", '').isEmpty
                                            ? "Video Hashtag can't be Empty"
                                            : null,
                                        onChanged: (val) {
                                          videoHashTag = val;
                                          if (_submitted) {
                                            _formKey.currentState.validate();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          prefix: Text('#'),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          hintText: "Enter hashtag",
                                          hintStyle: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: _fontOne * 15,
                                          ),
                                          errorStyle: TextStyle(
                                            fontSize: _fontOne * 15,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: _fontOne * 15,
                                        ),
                                      ),
                                      leftPadding: _widthOne * 20,
                                    ))
                                : FormFieldFormatting.formFieldContainer(
                                    child: TextFormField(
                                      initialValue: _videos[index].videoHashtag,
                                      keyboardType: TextInputType.text,
                                      validator: (val) => val.isEmpty ||
                                              val.replaceAll(" ", '').isEmpty
                                          ? "Video Hashtag can't be Empty"
                                          : null,
                                      onChanged: (val) {
                                        videoHashTag = val;
                                        if (_submitted) {
                                          _formKey.currentState.validate();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        prefix: Text('#'),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: "Enter hashtag",
                                        hintStyle: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: _fontOne * 15,
                                        ),
                                        errorStyle: TextStyle(
                                          fontSize: _fontOne * 15,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: _fontOne * 15,
                                      ),
                                    ),
                                    leftPadding: _widthOne * 20,
                                  ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: _widthOne * 20,
                              ),
                              width: _size.width * 0.87,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Platform.isIOS
                                  ? CupertinoButton(
                                      child: Text(category == null
                                          ? "Select a category"
                                          : category),
                                      onPressed: () {
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (_) {
                                              return Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                child: CupertinoPicker(
                                                  backgroundColor:
                                                      CupertinoColors
                                                          .systemGrey,
                                                  itemExtent: 32,
                                                  children: [
                                                    Center(
                                                        child: Text("Vocals")),
                                                    Center(
                                                        child: Text("Acting")),
                                                    Center(
                                                        child: Text(
                                                            "Instrumental")),
                                                    Center(
                                                        child: Text(
                                                            "Standup Comedy")),
                                                    Center(
                                                        child: Text("DJing")),
                                                    Center(
                                                        child: Text("Dance")),
                                                  ],
                                                  onSelectedItemChanged:
                                                      (index) {
                                                    _selectedCategory = index;
                                                    switch (index) {
                                                      case 0:
                                                        category = "Vocals";
                                                        break;
                                                      case 1:
                                                        category = "Acting";
                                                        break;
                                                      case 2:
                                                        category =
                                                            "Instrumental";
                                                        break;
                                                      case 3:
                                                        category =
                                                            "Standup Comedy";
                                                        break;
                                                      case 4:
                                                        category = "DJing";
                                                        break;
                                                      case 5:
                                                        category = "Dance";
                                                        break;
                                                    }
                                                    setState(() {});
                                                  },
                                                ),
                                              );
                                            });
                                      },
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                          value: _selectedCategory,
                                          dropdownColor:
                                              AppTheme.pureWhiteColor,
                                          items: [
                                            DropdownMenuItem(
                                              child: Text("Vocals",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColorDark)),
                                              value: 0,
                                            ),
                                            DropdownMenuItem(
                                              child: Text("Acting",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColorDark)),
                                              value: 1,
                                            ),
                                            DropdownMenuItem(
                                                child: Text("Instrumental",
                                                    style: TextStyle(
                                                        color: AppTheme
                                                            .primaryColorDark)),
                                                value: 2),
                                            DropdownMenuItem(
                                              child: Text("Standup Comedy",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColorDark)),
                                              value: 3,
                                            ),
                                            DropdownMenuItem(
                                              child: Text("DJing",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColorDark)),
                                              value: 4,
                                            ),
                                            DropdownMenuItem(
                                                child: Text("Dance",
                                                    style: TextStyle(
                                                        color: AppTheme
                                                            .primaryColorDark)),
                                                value: 5),
                                          ],
                                          onChanged: (value) {
                                            _selectedCategory = value;
                                            switch (value) {
                                              case 0:
                                                category = "Vocals";
                                                break;
                                              case 1:
                                                category = "Acting";
                                                break;
                                              case 2:
                                                category = "Instrumental";
                                                break;
                                              case 3:
                                                category = "Standup Comedy";
                                                break;
                                              case 4:
                                                category = "DJing";
                                                break;
                                              case 5:
                                                category = "Dance";
                                                break;
                                            }
                                            setState(() {});
                                          }),
                                    ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: Platform.isIOS
                                  ? [
                                      Container(
                                        width: _size.width * 0.30,
                                        decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            border: Border.all(
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: CupertinoButton(
                                            onPressed: () {
                                              removeVideoFromDrafts(index);
                                              setup();
                                            },
                                            child: _uploadingVideo
                                                ? CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.purple),
                                                  )
                                                : Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                      ),
                                      Container(
                                        width: _size.width * 0.30,
                                        decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            border: Border.all(
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: CupertinoButton(
                                            onPressed: () {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                moveVideoToPost(index);
                                                removeVideoFromDrafts(index);
                                                didUpload = true;
                                                setup();
                                              } else {
                                                setState(() {
                                                  _submitted = true;
                                                });
                                              }
                                            },
                                            child: _uploadingVideo
                                                ? CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.purple),
                                                  )
                                                : Text(
                                                    "Upload",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                      ),
                                    ]
                                  : [
                                      FlatButton(
                                          onPressed: () {
                                            removeVideoFromDrafts(index);
                                            setup();
                                          },
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: AppTheme.primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: _uploadingVideo
                                              ? CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppTheme
                                                              .primaryColor),
                                                )
                                              : Text("Delete")),
                                      FlatButton(
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              moveVideoToPost(index);
                                              removeVideoFromDrafts(index);
                                              didUpload = true;
                                              setup();
                                            } else {
                                              setState(() {
                                                _submitted = true;
                                              });
                                            }
                                          },
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: AppTheme.primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: _uploadingVideo
                                              ? CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppTheme
                                                              .primaryColor),
                                                )
                                              : Text("Upload")),
                                    ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          )
        : Center(
            child: Text(
              "No saved drafts",
              style: TextStyle(fontSize: 18, color: AppTheme.primaryColor),
            ),
          );
  }
}
