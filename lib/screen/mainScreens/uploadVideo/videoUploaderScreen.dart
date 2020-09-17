import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';
import '../../../model/video_info.dart';

class VideoUploader extends StatefulWidget {
  VideoUploader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  List<VideoInfo> _videos = <VideoInfo>[];
  MediaInfo mediaInfo;
  bool _imagePickerActive = false;
  bool _processingVideo = false;
  bool _uploadingVideo = false;
  bool _processed = false;
  bool _processingCameraVideo = false;
  bool _processingGalleryVideo = false;
  double _uploadProgress = 0.0;
  String _processPhase = '';
  double _fontOne;
  double _widthOne;
  Size _size;
  String videoName = "";
  String videoHashtag = "";
  String category = "Vocals";
  int _selectedCategory = 0;
  final _formKey = GlobalKey<FormState>();
  File thumbnailFile;
  double aspectRatio;
  UserAuth _userAuth = UserAuth();
  String mediaInfoPath=' ';
  String thumbnailInfoPath=' ';
  String infoPath=' ';
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

  Future<void> _processVideo(PickedFile rawVideoFile) async {
    print("processing");
    print(rawVideoFile.path);
    setState(() {
      _processPhase = 'Compressing video';
      _uploadProgress = 0.0;
    });
    mediaInfo = await VideoCompress.compressVideo(
      rawVideoFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // It's false by default
    );
    setState(() {
      _processPhase = 'Getting thumbnail';
      _uploadProgress = 0.0;
    });
    thumbnailFile = await VideoCompress.getFileThumbnail(
        rawVideoFile.path,
        quality: 100, // default(100)
        position: -1 // default(-1)
    );
    aspectRatio = mediaInfo.height/mediaInfo.width;
    mediaInfoPath = mediaInfo.path;
    thumbnailInfoPath = thumbnailFile.path;
    _processingCameraVideo = false;
    _processingGalleryVideo = false;
    setState(() {
    });
  }

  uploadToServer() async {
    _uploadingVideo = true;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final thumbUrl = await _uploadThumbnail(thumbnailFile.path, 'thumbnail/' + _userAuth.user.uid, timestamp.toString());
    setState(() {
      _processPhase = 'Saving video thumbnail to server';
      _uploadProgress = 0.0;
    });
    final videoUrl = await _uploadVideo(mediaInfo.path, 'videos/'+_userAuth.user.uid+videoName, timestamp.toString());
    setState(() {
      _processPhase = 'Saving video file to servers';
      _uploadProgress = 0.0;
    });
    final videoInfo = VideoInfo(
      uploaderUid: UserAuth().user.uid,
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      uploadedAt: timestamp,
      videoName: videoName,
      videoHashtag: videoHashtag,
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

  void _takeVideo(context, source) async {
    var videoFile;
    if (_imagePickerActive) return;
    _imagePickerActive = true;
    videoFile = await ImagePicker().getVideo(
        source: source, maxDuration: const Duration(seconds: 300));
    _imagePickerActive = false;

    if (videoFile == null) return;
    try {
      setState(() {
        _processingVideo = true;
      });
      await _processVideo(videoFile);
    } catch (e) {
      print("error" + '${e.toString()}');
    } finally {
      setState(() {
        _processingVideo = false;
        _processed = true;
      });
    }
    Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text('Encoding Completed')
        )
    );
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

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _fontOne = (_size.height * 0.015) / 11;
    _widthOne = _size.width * 0.0008;
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: _uploadingVideo
                ? _getProgressBar()
                : SingleChildScrollView(
                  child: Container(
              padding: EdgeInsets.all(50),
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
                      authFormFieldContainer(
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
                          decoration: authFormFieldFormatting(
                              hintText: "Enter Title",
                              fontSize: _fontOne * 15
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
                      authFormFieldContainer(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          validator: (val) => val.isEmpty || val.replaceAll(" ", '').isEmpty
                              ? "Video Hashtag can't be Empty"
                              : null,
                          onChanged: (val) {
                            videoHashtag = val;
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
                            hintText: "Enter a hashtag",
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
                        width: MediaQuery.of(context).size.width * 0.7,
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
                                    child: Text("Performing Arts"),
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
                              ],
                              onChanged: (value) {
                                _selectedCategory = value;
                                switch(value){
                                  case 0: category = "Vocals";break;
                                  case 1: category = "Percussions";break;
                                  case 2: category = "Performing Arts";break;
                                  case 3: category = "Instrumental";break;
                                  case 4: category = "Videography";break;
                                  case 5: category = "Standup Comedy";break;
                                  case 6: category = "DIY";break;
                                }
                                setState(() {
                                });
                              }),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width/10,
                      ),
                      Text(
                        "Pick your Video",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FlatButton(
                              onPressed: () {
                                _processingCameraVideo = true;
                                setState(() {
                                });
                                _takeVideo(context, ImageSource.camera);
                              },
                              //minWidth: MediaQuery.of(context).size.width * 0.5,
                              shape: RoundedRectangleBorder(
                                  side:
                                  BorderSide(color: Colors.orange.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(5)),
                              child: _processingCameraVideo
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.orange.withOpacity(0.5)
                                      ),
                                    ),
                                  )
                                  : Text("Camera")
                          ),
                          FlatButton(
                              onPressed: () {
                                _processingGalleryVideo = true;
                                setState(() {

                                });
                                _takeVideo(context, ImageSource.gallery);
                              },
                              //minWidth: MediaQuery.of(context).size.width * 0.5,
                              shape: RoundedRectangleBorder(
                                  side:
                                  BorderSide(color: Colors.orange.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(5)),
                              child: _processingGalleryVideo
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.orange.withOpacity(0.5)
                                        ),
                                      ),
                                    )
                                  : Text("Gallery")
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      FlatButton(
                          onPressed: (){
                            if(_formKey.currentState.validate()){
                              if(_processingVideo && (_processingGalleryVideo || _processingCameraVideo)){
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Wait for the video to encode')
                                    )
                                );
                              }
                              else if(_processed) {
                                uploadToServer();
                              }
                              else{
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Please select a video to upload')
                                    )
                                );
                              }
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
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.purple),
                          )
                              : Text("Upload")),
                    ],
                  ),
              ),
            ),
                ),
          ),
        ));
  }
}