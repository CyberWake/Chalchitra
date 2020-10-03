import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/helpers/formFiledFormatting.dart';

class Drafts extends StatefulWidget {
  @override
  _DraftsState createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  List<VideoInfo> _videos = <VideoInfo>[];
  final _formKey = GlobalKey<FormState>();
  String videoHashTag = "";
  String videoName = "";
  bool _uploadingVideo = false;
  double _fontOne;
  bool _submitted = false;
  int _selectedCategory = 0;
  String category = "Vocals";
  double _widthOne;
  Size _size;

  void setup() async{
    dynamic result = await UserVideoStore().getDraftVideos(
        uid: UserAuth().user.uid
    );
    if(result != false){
      setState(() {
        _videos = result;
      });
      print(_videos.length);
    }
  }

  removeVideoFromDrafts(index) async{
    final videoInfo = VideoInfo(
      videoUrl: _videos[index].videoUrl,
      thumbUrl: _videos[index].thumbUrl,
      coverUrl: _videos[index].coverUrl,
      videoId: _videos[index].videoId
    );
    await UserVideoStore.deleteVideoDraft(videoInfo);
  }

  moveVideoToPost(int index) async {
    _uploadingVideo = true;
    int timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
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
  }

  getCategory(String draftCategory){
    switch(draftCategory){
      case "Vocal": _selectedCategory = 0;break;
      case "Percussions": _selectedCategory = 1;break;
      case "Acting": _selectedCategory = 2;break;
      case "Instrumental": _selectedCategory = 3;break;
      case "Videography": _selectedCategory = 4;break;
      case "Standup Comedy": _selectedCategory = 5;break;
      case "DIY": _selectedCategory = 6;break;
      case "DJing": _selectedCategory = 7;break;
      case "Story Telling": _selectedCategory = 8;break;
      case "Dance": _selectedCategory = 9;break;
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _fontOne = (_size.height * 0.015) / 11;
    _widthOne = _size.width * 0.0008;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Drafts'),
      ),
      body: _videos.length>0?
       Form(
        key: _formKey,
        child: Container(
          child: ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (BuildContext context,int index){
                getCategory(_videos[index].category);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                              aspectRatio: _videos[index].aspectRatio,
                              child: Image.network(_videos[index].thumbUrl,fit: BoxFit.fitWidth,)
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.05,
                          ),
                          FormFieldFormatting.formFieldContainer(
                            child: TextFormField(
                              initialValue: _videos[index].videoHashtag,
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
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.05,
                          ),
                          FormFieldFormatting.formFieldContainer(
                            child: TextFormField(
                              initialValue: _videos[index].videoHashtag,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FlatButton(
                                  onPressed: (){
                                    removeVideoFromDrafts(index);
                                    setup();
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
                                      : Text("Delete")),
                              FlatButton(
                                  onPressed: (){
                                    if(_formKey.currentState.validate()){
                                      moveVideoToPost(index);
                                      removeVideoFromDrafts(index);
                                      setup();
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
                        ],
                      ),
                    ),
              );
            }
          ),
        ),
      )
          :Center(
        child: Text("No saved drafts",style: TextStyle(fontSize: 18,color: AppTheme.primaryColor),),
      )
    );
  }
}
