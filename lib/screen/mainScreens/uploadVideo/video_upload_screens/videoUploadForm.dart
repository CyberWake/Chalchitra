import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:Chalchitra/imports.dart';
import 'package:path/path.dart' as p;

class VideoUploadForm extends StatefulWidget {
  final String thumbnailPath;
  final String mediaInfoPath;
  final double aspectRatio;
  final bool isFromDraft;
  VideoUploadForm(
      {this.isFromDraft,
      this.aspectRatio,
      this.mediaInfoPath,
      this.thumbnailPath});
  @override
  _VideoUploadFormState createState() => _VideoUploadFormState();
}

class _VideoUploadFormState extends State<VideoUploadForm> {
  MediaInfo mediaInfo;
  bool _uploadingVideo = false;
  bool _uploadSuccess = false;
  bool _draftSaved = false;
  double _uploadProgress = 0.0;
  String _processPhase = '';
  double _fontOne;
  double _iconOne;
  double _widthOne;
  Size _size;
  String videoName = "";
  String videoHashTag = "";
  String category = "Vocals";
  int _selectedCategory = 0;
  File file;
  final _formKey = GlobalKey<FormState>();
  UserAuth _userAuth = UserAuth();
  bool _submitted = false;
  TextEditingController categoryController = TextEditingController();

  void _onUploadProgress(event) {
    if (event.type == StorageTaskEventType.progress) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        _uploadProgress = progress;
      });
    }
  }

  Future<String> _uploadVideo(filePath, folderName, timestamp) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);
    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(folderName)
        .child(timestamp + basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  Future<String> _uploadThumbnail(filePath, folderName, timestamp) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(folderName)
        .child(timestamp + basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  uploadToServer() async {
    UserDataModel user;
    UserInfoStore _userInfoStore = UserInfoStore();
    user = await _userInfoStore.getUserInformation(uid: UserAuth().user.uid);
    String currentUserUsername = user.username;
    String currentUserImgUrl = user.photoUrl;
    try {
      _uploadingVideo = true;
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        _processPhase = 'Uploading video thumbnail';
        _uploadProgress = 0.0;
      });
      final thumbUrl = await _uploadThumbnail(widget.thumbnailPath,
          'thumbnail/' + _userAuth.user.uid, timestamp.toString());
      setState(() {
        _processPhase = 'Uploading video file';
        _uploadProgress = 0.0;
      });
      final videoUrl = await _uploadVideo(widget.mediaInfoPath,
          'videos/' + _userAuth.user.uid + videoName, timestamp.toString());
      final videoInfo = VideoInfo(
          uploaderUid: UserAuth().user.uid,
          videoUrl: videoUrl,
          thumbUrl: thumbUrl,
          coverUrl: thumbUrl,
          aspectRatio: widget.aspectRatio,
          uploadedAt: timestamp,
          videoName: videoName,
          videoHashtag: videoHashTag,
          category: categoryController.text,
          likes: 0,
          views: 0,
          rating: 0,
          comments: 0,
          average: 0.0,
          uploaderName: currentUserUsername,
          uploaderPic: currentUserImgUrl,
        );

      await UserVideoStore.saveVideo(videoInfo);
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        setState(() {
          _processPhase = '';
          _uploadProgress = 0.0;
          _uploadingVideo = false;
          _uploadSuccess = true;
        });
      });
      UserDataModel user =
          await UserInfoStore().getUserInformation(uid: _userAuth.user.uid);
      Provider.of<CurrentUser>(context, listen: false).updateCurrentUser(user);
      await VideoCompress.deleteAllCache();
    } catch (e) {
      print(e.toString());
    }
    if (_uploadSuccess) {
      _buildUploadSuccess(context);
    }
  }

  uploadDraftToServer() async {
    UserDataModel user;
    UserInfoStore _userInfoStore = UserInfoStore();
    user = await _userInfoStore.getUserInformation(uid: UserAuth().user.uid);
    String currentUserUsername = user.username;
    String currentUserImgUrl = user.photoUrl;
    _uploadingVideo = true;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _processPhase = 'Saving video thumbnail to server';
      _uploadProgress = 0.0;
    });
    final thumbUrl = await _uploadThumbnail(widget.thumbnailPath,
        'thumbnail/' + _userAuth.user.uid, timestamp.toString());
    setState(() {
      _processPhase = 'Saving video file to servers';
      _uploadProgress = 0.0;
    });
    final videoUrl = await _uploadVideo(widget.mediaInfoPath,
        'videos/' + _userAuth.user.uid + videoName, timestamp.toString());
    final videoInfo = VideoInfo(
      uploaderUid: UserAuth().user.uid,
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: widget.aspectRatio,
      uploadedAt: timestamp,
      videoName: videoName,
      videoHashtag: videoHashTag,
      category: categoryController.text,
      likes: 0,
      views: 0,
      rating: 0,
      comments: 0,
      average: 0.0,
      uploaderName: currentUserUsername,
      uploaderPic: currentUserImgUrl,
    );

    await UserVideoStore.saveVideoDraft(videoInfo);
    setState(() {
      _processPhase = '';
      _uploadProgress = 0.0;
      _uploadingVideo = false;
      _uploadSuccess = true;
    });
    await VideoCompress.deleteAllCache();
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(
              _processPhase,
              style: TextStyle(color: AppTheme.pureWhiteColor),
            ),
          ),
          LinearPercentIndicator(
            alignment: MainAxisAlignment.center,
            width: MediaQuery.of(context).size.width * 0.75,
            animation: false,
            lineHeight: 20.0,
            animationDuration: 2500,
            percent: _uploadProgress,
            center: Text('${(_uploadProgress * 100).toStringAsFixed(2)}%',
                style: TextStyle(color: Colors.black)),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Colors.greenAccent[400],
          ),
        ],
      ),
    );
  }

  _buildConfirmDiscard(context) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ), //this right here
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border:
                          Border.all(color: AppTheme.pureWhiteColor, width: 3)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 10),
                          child: Text(
                            'Do you want to save this post as a draft?',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              BouncingButton(
                                buttonText: "No",
                                width: _size.width * 0.3,
                                buttonFunction: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              ),
                              BouncingButton(
                                buttonText: "Yes",
                                width: _size.width * 0.3,
                                buttonFunction: () {
                                  Navigator.pop(context);
                                  _draftSaved = true;
                                  uploadDraftToServer();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container(
            color: Colors.red,
          );
        });
  }

  _buildUploadSuccess(context) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ), //this right here
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border:
                          Border.all(color: AppTheme.primaryColor, width: 3)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 10),
                          child: Text(
                            _draftSaved
                                ? 'Draft Saved Successfully'
                                : _uploadSuccess
                                    ? 'Video Posted Succesfully'
                                    : 'Error somewhere',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: BouncingButton(
                            buttonText: "OK",
                            width: MediaQuery.of(context).size.width * 0.6,
                            buttonFunction: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container(
            color: Colors.red,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    file = File(widget.thumbnailPath);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _fontOne = (_size.height * 0.015) / 11;
    _widthOne = _size.width * 0.0008;
    _iconOne = (_size.height * 0.066) / 50;
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Platform.isIOS
                          ? CupertinoButton(
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: AppTheme.backgroundColor,
                              ),
                              onPressed: widget.isFromDraft
                                  ? () {
                                      Navigator.pop(context);
                                    }
                                  : () {
                                      if (_draftSaved) {
                                        Navigator.pop(context);
                                      } else {
                                        _buildConfirmDiscard(context);
                                      }
                                    })
                          : IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: AppTheme.backgroundColor,
                              ),
                              onPressed: () {
                                if (_draftSaved) {
                                  Navigator.pop(context);
                                } else {
                                  _buildConfirmDiscard(context);
                                }
                              }),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: InkWell(
                          child: Text(
                            "Discard",
                            style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            _buildConfirmDiscard(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _uploadingVideo
                    ? Center(child: _getProgressBar())
                    : !_uploadSuccess
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AspectRatio(
                                      //test
                                      // aspectRatio: 16/9,
                                      // child: Container(color: Colors.red,),
                                      aspectRatio: widget.aspectRatio,
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.fitWidth,
                                      )),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                  TextFormField(
                                    onChanged: (val) {
                                      videoName = val;
                                      if (_submitted) {
                                        _formKey.currentState.validate();
                                      }
                                    },
                                    style: TextStyle(
                                      color: AppTheme.pureWhiteColor,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    validator: (val) => val.isEmpty ||
                                            val.replaceAll(" ", '').isEmpty
                                        ? "Video Title can't be Empty"
                                        : null,
                                    decoration: InputDecoration(
                                        hintText: "Write a caption",
                                        hintStyle: TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppTheme.grey)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppTheme.grey)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    AppTheme.secondaryColor))),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    onChanged: (val) {
                                      videoHashTag = val;
                                      if (_submitted) {
                                        _formKey.currentState.validate();
                                      }
                                    },
                                    style: TextStyle(
                                        color: AppTheme.pureWhiteColor),
                                    validator: (val) => val.isEmpty ||
                                            val.replaceAll(" ", '').isEmpty
                                        ? "Video Hashtag can't be Empty"
                                        : null,
                                    decoration: InputDecoration(
                                        hintText: "Add hashtag",
                                        hintStyle:
                                            TextStyle(color: AppTheme.grey),
                                        prefix: Text("#",
                                            style: TextStyle(fontSize: 20)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppTheme.grey)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppTheme.grey)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    AppTheme.secondaryColor))),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
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
                                                    backgroundColor:
                                                        CupertinoColors.systemGrey,
                                                    itemExtent: 32,
                                                    children: [
                                                      Center(child: Text("Vocals")),
                                                      Center(child: Text("Dance")),
                                                      Center(
                                                          child:
                                                              Text("Instrumental")),
                                                      Center(
                                                          child:
                                                              Text("Stand-up Comedy")),
                                                      Center(child: Text("DJing")),
                                                      Center(child: Text("Acting")),
                                                    ],
                                                    onSelectedItemChanged: (index) {
                                                      _selectedCategory = index;
                                                      switch (index) {
                                                        case 0:
                                                          categoryController.text =
                                                              "Vocals";
                                                          break;
                                                        case 1:
                                                          categoryController.text =
                                                              "Dance";
                                                          break;
                                                        case 2:
                                                          categoryController.text =
                                                              "Instrumental";
                                                          break;
                                                        case 3:
                                                          categoryController.text =
                                                              "Stand-up Comedy";
                                                          break;
                                                        case 4:
                                                          categoryController.text =
                                                              "DJing";
                                                          break;
                                                        case 5:
                                                          categoryController.text =
                                                              "Acting";
                                                          break;
                                                      }
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: categoryController,
                                        style: TextStyle(
                                            color: AppTheme.pureWhiteColor),
                                        decoration: InputDecoration(
                                            hintText: "Category",
                                            hintStyle:
                                                TextStyle(color: AppTheme.grey),
                                            suffixIcon: Icon(
                                              Icons.arrow_drop_down,
                                              color: AppTheme.secondaryColor,
                                            ),
                                            border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppTheme.grey)),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppTheme.grey)),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppTheme
                                                        .secondaryColor))),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: widget.isFromDraft
                                        ? [
                                            RaisedButton(
                                              onPressed: () {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  uploadToServer();
                                                  setState(() {
                                                    _uploadSuccess = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _submitted = true;
                                                  });
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 12, 18, 12),
                                                child: Text(
                                                  "POST",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme
                                                          .pureWhiteColor),
                                                ),
                                              ),
                                              color: AppTheme.secondaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                            )
                                          ]
                                        : [
                                            RaisedButton(
                                              onPressed: () {
                                                _draftSaved = true;
                                                uploadDraftToServer();
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 12, 18, 12),
                                                child: Text(
                                                  "SAVE",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme
                                                          .secondaryColor),
                                                ),
                                              ),
                                              color: AppTheme.pureWhiteColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                            ),
                                            RaisedButton(
                                              onPressed: () {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  uploadToServer();
                                                  setState(() {
                                                    _uploadSuccess = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _submitted = true;
                                                  });
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 12, 18, 12),
                                                child: Text(
                                                  "POST",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme
                                                          .pureWhiteColor),
                                                ),
                                              ),
                                              color: AppTheme.secondaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                            )
                                          ],
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
