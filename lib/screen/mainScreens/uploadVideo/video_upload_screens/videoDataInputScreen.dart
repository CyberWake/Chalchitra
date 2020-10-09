import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';

class VideoDataInput extends StatefulWidget {
  final String thumbnailPath;
  final String mediaInfoPath;
  final double aspectRatio;

  VideoDataInput({this.mediaInfoPath, this.thumbnailPath, this.aspectRatio});

  @override
  _VideoDataInputState createState() => _VideoDataInputState();
}

class _VideoDataInputState extends State<VideoDataInput> {
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
      category: category,
      likes: 0,
      views: 0,
      rating: 0,
      comments: 0,
    );

    await UserVideoStore.saveVideo(videoInfo);
    setState(() {
      _processPhase = '';
      _uploadProgress = 0.0;
      _uploadingVideo = false;
      _uploadSuccess = true;
    });
    await VideoCompress.deleteAllCache();
  }

  uploadDraftToServer() async {
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
      category: category,
      likes: 0,
      views: 0,
      rating: 0,
      comments: 0,
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
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _uploadProgress,
          ),
        ],
      ),
    );
  }

  _buildConfirmDiscard(context) {
    return Platform.isIOS ? CupertinoAlertDialog(
      content: Text(
        'Do you want to save this post as a draft?',
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text(
            "No",
          ),
        ),
        CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
            _draftSaved = true;
            uploadDraftToServer();
          },
          child: Text(
            "Yes",
          ),
        ),
      ],
    ) :  Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ), //this right here
      child: Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppTheme.pureWhiteColor, width: 3)),
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
                    SizedBox(
                      width: _size.width * 0.3,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: AppTheme.primaryColor, width: 2)),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text(
                            "No",
                            style: TextStyle(color: AppTheme.pureWhiteColor),
                          ),
                          color: AppTheme.primaryColor),
                    ),
                    SizedBox(
                      width: _size.width * 0.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: AppTheme.primaryColor, width: 2)),
                        onPressed: () {
                          Navigator.pop(context);
                          _draftSaved = true;
                          uploadDraftToServer();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: AppTheme.pureWhiteColor),
                        ),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  _buildUploadSuccess(context) {
    return Platform.isIOS ? CupertinoAlertDialog(
      content: Text(
        _draftSaved? 'Draft Saved Successfully': _uploadSuccess?'Video Posted Succesfully':'Error somewhere',
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
            ),
        ),
      ],
    ) : Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ), //this right here
      child: Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppTheme.pureWhiteColor, width: 3)),
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
                child: SizedBox(
                  width: _size.width * 0.3,
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                              color: AppTheme.primaryColor, width: 2)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(color: AppTheme.pureWhiteColor),
                      ),
                      color: AppTheme.primaryColor),
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
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
    return Platform.isIOS ? videoDataInputiOS() : Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: AppTheme.primaryColor,
          title: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            height: 55,
            width: _size.width / 2.5,
            child: Image.asset(
              'assets/images/appBarLogo1.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.pureWhiteColor,
                size: _iconOne * 30,
              ),
              onPressed: () {
                if (_draftSaved) {
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildConfirmDiscard(context),
                  );
                }
              }),
          actions: [
            IconButton(
              icon: Icon(
                Icons.save,
                color: AppTheme.pureWhiteColor,
                size: _iconOne * 30,
              ),
              onPressed: () {
                _draftSaved = true;
                uploadDraftToServer();
              },
            )
          ],
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _uploadingVideo
                ? Center(child: _getProgressBar())
                : !_uploadSuccess
                    ? SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                )
                              ]),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AspectRatio(
                                    aspectRatio: widget.aspectRatio,
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.fitWidth,
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                FormFieldFormatting.formFieldContainer(
                                  child: TextFormField(
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
                                        color: AppTheme.pureWhiteColor,
                                        fontSize: _fontOne * 15,
                                      ),
                                      errorStyle: TextStyle(
                                        fontSize: _fontOne * 15,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: AppTheme.pureWhiteColor,
                                      fontSize: _fontOne * 15,
                                    ),
                                  ),
                                  leftPadding: _widthOne * 20,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                FormFieldFormatting.formFieldContainer(
                                  child: TextFormField(
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
                                        color: AppTheme.pureWhiteColor,
                                        fontSize: _fontOne * 15,
                                      ),
                                      errorStyle: TextStyle(
                                        fontSize: _fontOne * 15,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: AppTheme.pureWhiteColor,
                                      fontSize: _fontOne * 15,
                                    ),
                                  ),
                                  leftPadding: _widthOne * 20,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: _widthOne * 20,
                                  ),
                                  width: _size.width * 0.87,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        value: _selectedCategory,
                                        dropdownColor: AppTheme.elevationColor,
                                        items: [
                                          DropdownMenuItem(
                                            child: Text("Vocals",
                                                style: TextStyle(
                                                    color:
                                                        AppTheme.primaryColor)),
                                            value: 0,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Dance",
                                                style: TextStyle(
                                                    color:
                                                        AppTheme.primaryColor)),
                                            value: 1,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Instrumental",
                                                style: TextStyle(
                                                    color:
                                                        AppTheme.primaryColor)),
                                            value: 2,
                                          ),
                                          DropdownMenuItem(
                                              child: Text("Standup Comedy",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColor)),
                                              value: 3),
                                          DropdownMenuItem(
                                              child: Text("DJing",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColor)),
                                              value: 4),
                                          DropdownMenuItem(
                                              child: Text("Acting",
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .primaryColor)),
                                              value: 5),
                                        ],
                                        onChanged: (value) {
                                          _selectedCategory = value;
                                          switch (value) {
                                            case 0:
                                              category = "Vocals";
                                              break;
                                            case 1:
                                              category = "Dance";
                                              break;
                                            case 2:
                                              category = "Instrumental";
                                              break;
                                            case 3:
                                              category = "Story Telling";
                                              break;
                                            case 4:
                                              category = "DJing";
                                              break;
                                            case 5:
                                              category = "Acting";
                                              break;
                                          }
                                          setState(() {});
                                        }),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 10,
                                ),
                                FlatButton(
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
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
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: AppTheme.primaryColor),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: _uploadingVideo
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.purple),
                                          )
                                        : Text("Upload",
                                            style: TextStyle(
                                                color: AppTheme.primaryColor))),
                              ],
                            ),
                          ),
                        ),
                      )
                    : _buildUploadSuccess(context)));
  }

  Widget videoDataInputiOS(){
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.primaryColor,
        middle: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          height: 55,
          width: _size.width / 2.5,
          child: Image.asset('assets/images/appBarLogo1.png',fit: BoxFit.fitHeight,),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Icon(
            Icons.save,
            color: Colors.black,
            size: _iconOne * 30,
          ),
          onPressed: (){
            _draftSaved = true;
            uploadDraftToServer();
          },
        ),

      ),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _uploadingVideo
              ? Center(child: _getProgressBar())
              : !_uploadSuccess
              ? SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.15),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ]),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                        aspectRatio: widget.aspectRatio,
                        child: Image.file(file,fit: BoxFit.fitWidth,)
                    ),
                    Material(
                      color: AppTheme.backgroundColor,
                      child:FormFieldFormatting.formFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (val) => val.isEmpty || val.replaceAll(" ", '').isEmpty
                            ? "Video Title can't be Empty"
                            : null,
                        onChanged: (val) {
                          videoName = val;
                          if(_submitted){
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
                            color: Colors.orange.withOpacity(0.75),
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
                    ),),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    Material(
                      color: AppTheme.backgroundColor,
                      child:FormFieldFormatting.formFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (val) => val.isEmpty || val.replaceAll(" ", '').isEmpty
                            ? "Video Hashtag can't be Empty"
                            : null,
                        onChanged: (val) {
                          videoHashTag = val;
                          if(_submitted){
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
                            color: Colors.orange.withOpacity(0.75),
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
                    ),),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoTheme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child:CupertinoButton(
                      child: Text(category==null ? "Select a category":category),
                      onPressed: (){
                        showCupertinoModalPopup(context: context, builder: (_){
                          return Container(
                            height: MediaQuery.of(context).size.height*0.2,
                            child: CupertinoPicker(
                              backgroundColor: CupertinoColors.systemGrey,
                              itemExtent: 32,
                              children: [
                                Center(child:Text("Vocals")),
                                Center(child:Text("Dance")),
                                Center(child:Text("Instrumental")),
                                Center(child:Text("Standup Comedy")),
                                Center(child:Text("DJing")),
                                Center(child:Text("Acting")),
                              ],
                              onSelectedItemChanged: (index){
                                _selectedCategory = index;
                                switch(index){
                                  case 0: category = "Vocals";break;
                                  case 1: category = "Dance";break;
                                  case 2: category = "Instrumental";break;
                                  case 3: category = "Standup Comedy";break;
                                  case 4: category = "DJing";break;
                                  case 5: category = "Acting";break;
                                }
                                setState(() {
                                });
                              },
                            ),
                          );
                        });
                      },
                    ),),
                    SizedBox(
                      height: MediaQuery.of(context).size.width/10,
                    ),
                    CupertinoButton(
                      color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            uploadToServer();
                            setState(() {
                              _uploadSuccess = true;
                            });
                          }else{
                            setState(() {
                              _submitted = true;
                            });
                          }
                        },
                        child: _uploadingVideo
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple),
                        )
                            : Text("Upload")),
                  ],
                ),
              ),
            ),
          )
              :_buildUploadSuccess(context)
      ),
    );
  }
}
