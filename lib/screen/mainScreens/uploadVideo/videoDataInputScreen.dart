import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:path/path.dart' as p;
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import 'package:wowtalent/model/videoInfoModel.dart';

class VideoDataInput extends StatefulWidget {
  final String thumbnailPath;
  final String mediainfoPath;
  final double aspectRatio;

  VideoDataInput({this.mediainfoPath,this.thumbnailPath,this.aspectRatio});

  @override
  _VideoDataInputState createState() => _VideoDataInputState();
}

class _VideoDataInputState extends State<VideoDataInput> {
  MediaInfo mediaInfo;
  bool _uploadingVideo = false;
  double _uploadProgress = 0.0;
  String _processPhase = '';
  double _fontOne;
  double _iconOne;
  double _widthOne;
  Size _size;
  String videoName = "";
  String videoDiscription = "";
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
    final StorageReference ref =
    FirebaseStorage.instance.ref().child(folderName).child(timestamp + basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  Future<String> _uploadThumbnail(filePath, folderName, timestamp) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final StorageReference ref =
    FirebaseStorage.instance.ref().child(folderName).child(timestamp + basename);
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
    final thumbUrl = await _uploadThumbnail(widget.thumbnailPath, 'thumbnail/' + _userAuth.user.uid, timestamp.toString());
    setState(() {
      _processPhase = 'Saving video file to servers';
      _uploadProgress = 0.0;
    });
    final videoUrl = await _uploadVideo(widget.mediainfoPath, 'videos/'+_userAuth.user.uid+videoName, timestamp.toString());
    final videoInfo = VideoInfo(
      uploaderUid: UserAuth().user.uid,
      videoDiscription: videoDiscription,
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20.0),
      ), //this right here
      child: Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.orange,width: 3)
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0,left: 10),
                child: Text(
                  'Do you really want to discard or save the post as draft?',
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
                            side: BorderSide(color: Colors.orange,width: 2)
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Discard",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    ),
                    SizedBox(
                      width: _size.width * 0.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.orange,width: 2)
                        ),
                        onPressed: () {

                        },
                        child: Text(
                          "Save as Draft",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.orange,
        title: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          height: 55,
          width: _size.width / 2.5,
          child: Image.asset('assets/images/appBarLogo1.png',fit: BoxFit.fitHeight,),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: _iconOne * 30,
          ),
          onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildConfirmDiscard(context),
            );
          }
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.black,
              size: _iconOne * 30,
            ),
            onPressed: (){
            },
          )
        ],
      ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _uploadingVideo
              ? Center(child: _getProgressBar())
              : SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
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
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: _size.height * 0.2,
                          width: _size.width * 0.2,
                          child: Image.file(file,fit: BoxFit.fitWidth,)
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: _widthOne * 20,
                          ),
                          width: _size.width / 1.6,
                          height: _size.height * 0.2,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.75)
                              ),
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: TextFormField(
                            maxLines: 5,
                            keyboardType: TextInputType.text,
                            validator: (val) => val.isEmpty || val.replaceAll(" ", '').isEmpty
                                ? "Video Description can't be Empty"
                                : null,
                            onChanged: (val) {
                              videoDiscription = val;
                              if(_submitted){
                                _formKey.currentState.validate();
                              }
                            },
                            decoration:  InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Enter Description",
                              errorMaxLines: 3,
                              hintStyle: TextStyle(
                                  color: Colors.orange.withOpacity(0.75),
                                  fontSize: _fontOne * 15
                              ),
                              errorStyle: TextStyle(
                                  fontSize: _fontOne * 15
                              ),
                            ),
                            style: TextStyle(
                              fontSize: _fontOne * 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    FormFieldFormatting.formFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (val) => val.isEmpty || val.replaceAll(" ", '').isEmpty
                            ? "Video Title can't be Empty"
                            : null,
                        onChanged: (val) {
                          videoHashTag = val;
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
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    FormFieldFormatting.formFieldContainer(
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
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.75)
                          ),
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            value: _selectedCategory,
                            items: [
                              DropdownMenuItem(
                                child: Text("Vocals"),
                                value: 0,
                              ),
                              DropdownMenuItem(
                                child: Text("Percussions"),
                                value: 1,
                              ),
                              DropdownMenuItem(
                                  child: Text("Acting"),
                                  value: 2
                              ),
                              DropdownMenuItem(
                                child: Text("Instrumental"),
                                value: 3,
                              ),
                              DropdownMenuItem(
                                child: Text("Videography"),
                                value: 4,
                              ),
                              DropdownMenuItem(
                                  child: Text("Standup Comedy"),
                                  value: 5
                              ),
                              DropdownMenuItem(
                                  child: Text("DIY"),
                                  value: 6
                              ),
                              DropdownMenuItem(
                                  child: Text("DJing"),
                                  value: 7
                              ),
                              DropdownMenuItem(
                                  child: Text("Story Telling"),
                                  value: 8
                              ),
                              DropdownMenuItem(
                                  child: Text("Dance"),
                                  value: 9
                              ),
                            ],
                            onChanged: (value) {
                              _selectedCategory = value;
                              switch(value){
                                case 0: category = "Vocals";break;
                                case 1: category = "Percussions";break;
                                case 2: category = "Acting";break;
                                case 3: category = "Instrumental";break;
                                case 4: category = "Videography";break;
                                case 5: category = "Standup Comedy";break;
                                case 6: category = "DIY";break;
                                case 7: category = "DJing";break;
                                case 8: category = "Story Telling";break;
                                case 9: category = "Dance";break;
                              }
                              setState(() {
                              });
                            }),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width/10,
                    ),
                    FlatButton(
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            uploadToServer();
                          }else{
                            setState(() {
                              _submitted = true;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                            side:
                            BorderSide(color: Colors.purple.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5)),
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
          ),
        ));
  }
}