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
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  double _fontOne;
  double _widthOne;
  Size _size;
  String videoName = "";
  final _formKey = GlobalKey<FormState>();
  UserAuth _userAuth = UserAuth();
  String mediaInfoPath=' ';
  String thumbnailInfoPath=' ';
  String infoPath=' ';

  void _onUploadProgress(event) {
    if (event.type == StorageTaskEventType.progress) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        _progress = progress;
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
    MediaInfo mediaInfo = await VideoCompress.compressVideo(
      rawVideoFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // It's false by default
    );

    final thumbnailFile = await VideoCompress.getFileThumbnail(
        rawVideoFile.path,
        quality: 100, // default(100)
        position: -1 // default(-1)
    );
    final aspectRatio = mediaInfo.height/mediaInfo.width;
    mediaInfoPath = mediaInfo.path;
    thumbnailInfoPath = thumbnailFile.path;
    setState(() {
    });
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final thumbUrl = await _uploadThumbnail(thumbnailFile.path, 'thumbnail/' + _userAuth.user.uid, timestamp.toString());
    final videoUrl = await _uploadVideo(mediaInfo.path, 'videos/'+_userAuth.user.uid+videoName, timestamp.toString());
    final videoInfo = VideoInfo(
      uploaderUid: UserAuth().user.uid,
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      uploadedAt: timestamp,
      videoName: videoName,
      likes: 0,
      views: 0,
      rating: 0,
      comments: 0,
    );
    setState(() {
      _processPhase = 'Saving video metadata to cloud firestore';
      _progress = 0.0;
    });
    await UserVideoStore.saveVideo(videoInfo);
    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
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
      await _processVideo(videoFile);
    } catch (e) {
      print("error" + '${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
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
            child: _processing
                ? Container()
                : Container(
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
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val.isEmpty || val.replaceAll(" ", '').isEmpty
                        ? "Video Title can't be Empty"
                            : null,
                        onChanged: (val) {
                          videoName = val;
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
                      height: MediaQuery.of(context).size.width/10,
                    ),
                    Text(
                      "Pick your Video",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      color: Colors.blue,
                      child: FittedBox(child: Text(mediaInfoPath,style: TextStyle(fontSize: 20),)),
                    ),
                    Container(
                      color: Colors.blue,
                      child: FittedBox(child: Text(thumbnailInfoPath,style: TextStyle(fontSize: 20),)),
                    ),
                    Container(
                      color: Colors.blue,
                      child: FittedBox(child: Text(infoPath,style: TextStyle(fontSize: 20),)),
                    ),
                    FlatButton(
                        onPressed: () {
                          if(_formKey.currentState.validate()){
                            _takeVideo(context, ImageSource.camera);
                          }
                        },
                        //minWidth: MediaQuery.of(context).size.width * 0.5,
                        shape: RoundedRectangleBorder(
                            side:
                            BorderSide(color: Colors.purple.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5)),
                        child: _processing
                            ? CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        )
                            : Text("Camera")),
                    FlatButton(
                        onPressed: () {
                          if(_formKey.currentState.validate()){
                            _takeVideo(context, ImageSource.gallery);
                          }
                        },
                        //minWidth: MediaQuery.of(context).size.width * 0.5,
                        shape: RoundedRectangleBorder(
                            side:
                            BorderSide(color: Colors.purple.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5)),
                        child: _processing
                            ? CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        )
                            : Text("Gallery")),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}