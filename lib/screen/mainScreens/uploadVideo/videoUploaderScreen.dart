import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_uploader_widget/encoding_provider.dart';
import '../../../model/video_info.dart';

class VideoUploader extends StatefulWidget {
  VideoUploader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  Size _size;

  @override
  void initState() {
    EncodingProvider.enableStatisticsCallback((int time,
        int size,
        double bitrate,
        double speed,
        int videoFrameNumber,
        double videoQuality,
        double videoFps) {
      if (_canceled) return;

      setState(() {
        _progress = time / _videoDuration;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Center(
      child: _processing ? _getProgressBar() : Container(
        padding: EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          )]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pick your Video",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.0,
            ),
            FlatButton(
              minWidth: _size.width * 0.5,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text("Use Camera"),
              onPressed: () {
                _takeVideo(context, ImageSource.camera);
              },
            ),
            FlatButton(
              minWidth: _size.width * 0.5,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Text("Use Gallery"),
              onPressed: () {
                _takeVideo(context, ImageSource.gallery);
              },
            )
          ],
        ),
      ),
    );
  }

  void _onUploadProgress(event) {
    if (event.type == StorageTaskEventType.progress) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        _progress = progress;
      });
    }
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final User firebaseUser = UserAuth().user;
    String uid = firebaseUser.uid;

    final file = new File(filePath);
    final basename = p.basename(filePath);

    final StorageReference ref =
        FirebaseStorage.instance.ref().child(folderName).child(basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8') _updatePlaylistUrls(file, videoName);

      setState(() {
        _processPhase = 'Uploading video file $i out of ${files.length}';
        _progress = 0.0;
      });

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  createAlertDialogue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Your video exceed limits, Please re-upload!!!"),
            actions: [
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _processVideo(File rawVideoFile) async {
    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final copyPath = '$outDirPath/copy.mp4';
    File(rawVideoPath).copySync(copyPath);
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio = EncodingProvider.getAspectRatio(info);
    print("printing Information ==================================>");
    print(info['streams'][0]['width']);
    print(info['streams'][0]['height']);
    final thumbWidth = info['streams'][0]['width'];
    final thumbHeight = info['streams'][0]['height'];

    setState(() {
      _processPhase = 'Generating thumbnail';
      _videoDuration = EncodingProvider.getDuration(info);
      print(_videoDuration);
      _progress = 0.0;
    });

    if (_videoDuration <= 30000 || _videoDuration >= 360000) {
      createAlertDialogue(context);

      print("video duration exceed");
      return null;
    }

    final thumbFilePath = await EncodingProvider.getThumb(
        copyPath, outDirPath, thumbWidth, thumbHeight);

    setState(() {
      _processPhase = 'Encoding video';
      _progress = 0.0;
    });

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      _processPhase = 'Uploading thumbnail to firebase storage';
      _progress = 0.0;
    });
    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: videoName,
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
  }

  void _takeVideo(context, source) async {
    var videoFile;
    if (_imagePickerActive){
      return;
    }
    else{
      _imagePickerActive = true;
      videoFile = await ImagePicker().getVideo(
          source: source, maxDuration: const Duration(seconds: 300)).then((value){
        print("hi");
      });
      _imagePickerActive = false;
    }

    if (videoFile == null){
      print("ehl");
      setState(() {
        _processing = false;
      });
      return;
    }
    else{
      setState(() {
        _processing = true;
      });
    }
    try {
      await _processVideo(videoFile);
    } catch (e) {
      print('${e.toString()}');
      setState(() {
        _processing = false;
      });
    } finally {
      setState(() {
        _processing = false;
      });
    }
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
            value: _progress,
          ),
        ],
      ),
    );
  }
}
