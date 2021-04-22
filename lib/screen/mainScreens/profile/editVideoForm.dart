import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Chalchitra/imports.dart';

class EditVideoForm extends StatefulWidget {
  final VideoInfo video;
  EditVideoForm({this.video});
  @override
  _EditVideoFormState createState() => _EditVideoFormState();
}

class _EditVideoFormState extends State<EditVideoForm> {
  VideoInfo _videoInfo;
  Size _size;
  TextEditingController _videoName;
  TextEditingController _hashtag;
  TextEditingController _category;
  int _selectedCategory = 0;
  bool _loading =true;

  @override
  void initState() {
    print(widget.video.videoId);
     _videoName = TextEditingController(text: widget.video.videoName);
      _hashtag =TextEditingController(text: widget.video.videoHashtag);
      _category = TextEditingController(text: widget.video.category);
      _videoInfo = widget.video;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    print("as:${_videoInfo.aspectRatio}");
    _size = MediaQuery.of(context).size;
    return Material(
      color:Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(15),
        color: AppTheme.primaryColor,
        child:SafeArea(
          bottom: false,
            child: SingleChildScrollView(
                          child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios,color: AppTheme.pureWhiteColor,),
                        onPressed: (){Navigator.pop(context);},
                      ),
                  ],
                ),
                AspectRatio(
                  aspectRatio: _videoInfo.aspectRatio,
                  child: CachedNetworkImage(
                    imageUrl: _videoInfo.thumbUrl,
                    imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Shimmer.fromColors(
                        highlightColor: AppTheme.pureWhiteColor,
                        baseColor: AppTheme.backgroundColor,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            color: AppTheme.backgroundColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(
                                    height: MediaQuery.of(context).size.width * 0.05,
                                  ),
                            TextFormField(
                              controller: _videoName,
                              style: TextStyle(color: AppTheme.pureWhiteColor),
                              validator: (val) => val.isEmpty ||
                                                          val.replaceAll(" ", '').isEmpty
                                                      ? "Video Title can't be Empty"
                                                      : null,
                              decoration: InputDecoration(
                                hintText: "Write a caption",
                                hintStyle: TextStyle(
                                  color: AppTheme.grey
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.grey
                                  )
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.grey
                                  )
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.secondaryColor
                                  )
                                )
                              ),
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _hashtag,
                              style: TextStyle(color: AppTheme.pureWhiteColor),
                              validator: (val) => val.isEmpty ||
                                                          val.replaceAll(" ", '').isEmpty
                                                      ? "Video Hashtag can't be Empty"
                                                      : null,
                              decoration: InputDecoration(
                                hintText: "Add hashtag",
                                hintStyle: TextStyle(
                                  color: AppTheme.grey
                                ),
                                prefix: Text("#",style: TextStyle(fontSize: 20)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.grey
                                  )
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.grey
                                  )
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.secondaryColor
                                  )
                                )
                              ),
                            ),
                            SizedBox(height: 20,),
                             InkWell(
                  onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: (_) {
                          return Container(
                              height: _size.height * 0.3,
                              child: CupertinoPicker(
                                                            backgroundColor:
                                                                CupertinoColors
                                                                    .systemGrey,
                                                            itemExtent: 32,
                                                            children: [
                                                              Center(
                                                                  child: Text("Vocals")),
                                                              Center(
                                                                  child: Text("Dance")),
                                                              Center(
                                                                  child: Text(
                                                                      "Instrumental")),
                                                              Center(
                                                                  child: Text(
                                                                      "Standup Comedy")),
                                                              Center(
                                                                  child: Text("DJing")),
                                                              Center(
                                                                  child: Text("Acting")),
                                                            ],
                                                            onSelectedItemChanged:
                                                                (index) {
                                                              _selectedCategory = index;
                                                              switch (index) {
                                                                case 0:
                                                                  _category.text = "Vocals";
                                                                  break;
                                                                case 1:
                                                                  _category.text = "Dance";
                                                                  break;
                                                                case 2:
                                                                  _category.text =
                                                                      "Instrumental";
                                                                  break;
                                                                case 3:
                                                                  _category.text =
                                                                      "Standup Comedy";
                                                                  break;
                                                                case 4:
                                                                  _category.text = "DJing";
                                                                  break;
                                                                case 5:
                                                                  _category.text = "Acting";
                                                                  break;
                                                              }
                                                              setState(() {});
                                                            },
                                                          ),);
                        }),
                  child: IgnorePointer(
                      child: TextFormField(
                        controller: _category,
                        style: TextStyle(color: AppTheme.pureWhiteColor),
                        decoration:InputDecoration(
                                hintText: "Category",
                                hintStyle: TextStyle(
                                  color: AppTheme.grey
                                ),
                                suffixIcon: Icon(Icons.arrow_drop_down,color: AppTheme.secondaryColor,),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.grey
                                  )
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.grey
                                  )
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.secondaryColor
                                  )
                                )
                              ),
                      ),
                  ),
                ),
                RaisedButton(onPressed: (){
                  _videoInfo.videoName = _videoName.text;
                  _videoInfo.videoHashtag=_hashtag.text;
                  _videoInfo.category = _category.text;
                  UserVideoStore().updateVideoInfo(id: widget.video.videoId,vidName: _videoName.text,hashTag: _hashtag.text,category: _category.text).then((value){if(value){
                    cupertinoSnackbar(context, "Success");
                    Navigator.pop(context);
                    Navigator.pop(context,_videoInfo!=null?_videoInfo:widget.video);
                  }});
                  },
                  child: Text("Update",style: TextStyle(color: AppTheme.pureWhiteColor),),color: AppTheme.secondaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),))
              ],
          ),
            ),
        ),
      ),
    );
  }
}