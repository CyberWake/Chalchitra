import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/menuConstants.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_uploader_widget/player.dart';

class PostCard extends StatefulWidget {
  final video;
  final String title, uploadTime, thumbnail, profileImg, uploader, id;
  final int commentCount, likeCount, viewCount;
  final int rating;

  PostCard({
    this.video,
    this.id,
    this.title,
    this.commentCount,
    this.likeCount,
    this.uploadTime,
    this.thumbnail,
    this.profileImg,
    this.uploader,
    this.viewCount,
    this.rating,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  double _widthOne;
  double _heightOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  double _sliderValue;
  UserVideoStore _userVideoStore = UserVideoStore();
  UserDataModel _user = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  bool _isLiked;
  int likeCount;
  bool _processing = false;

  void _button(Offset offset) async{
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0, 0),
        items:[
          PopupMenuItem(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 5,),
                InkWell(
                  onTap: () => choiceAction(Menu.Share),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Menu.Share),
                      Icon(Icons.share,size: 18,color: Colors.blueAccent),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                InkWell(
                  onTap: () => choiceAction(Menu.Download),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Menu.Download),
                      Icon(Icons.arrow_downward,size: 20,color: Colors.green),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                InkWell(
                  onTap: () => choiceAction(Menu.Forward),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Menu.Forward),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(Icons.reply,size: 20,color: Colors.orangeAccent,),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5,),
              ],
            ),
          )
        ]
    );
  }
  void choiceAction(String choice){
    print('called');
    if(choice == Menu.Share){
      print('Share');
    }else if(choice == Menu.Download){
      print('Download');
    }else if(choice == Menu.Forward){
      print('Forward');
    }
  }
  void setup() async{
    DocumentSnapshot user = await _userInfoStore.getUserInfo(
        uid: widget.video.data()['uploaderUid']
    );
    _user =  UserDataModel.fromDocument(user);
    _sliderValue = await
    _userVideoStore.checkRated(videoID:widget.id);
    _isLiked = await _userVideoStore.checkLiked(
      videoID: widget.id
    );
    likeCount = widget.likeCount;
    if(this.mounted){
      setState(() {});
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
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Container(
      height: _size.height * 0.4,
      width: _size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          offset: Offset(0.0, 0.0), //(x,y)
          blurRadius: 15.0,
        ),],
      ),
      child: Padding(
        padding: EdgeInsets.all(_fontOne * 12.5),
        child: _isLiked == null ? Container() : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: _fontOne * 40,
                  height: _heightOne * 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        widget.profileImg
                      )
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                SizedBox(width: _widthOne * 40,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: _fontOne * 14
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _heightOne * 1.5,),
                      Text(
                        widget.uploader,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: _fontOne * 12,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: _widthOne * 10,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.grey,
                        size: _iconOne * 20
                      ),
                      onTapDown: (TapDownDetails details) {
                        _button(details.globalPosition);
                      },
                    ),
                    Text(
                      widget.uploadTime,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: _fontOne * 10,
                        color: Colors.grey
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: _heightOne * 15,),
            Expanded(
              child: InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        VideoInfo video = VideoInfo.fromDocument(widget.video);
                        video.videoId = widget.id;
                        return Player(
                          video: video,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    color: Colors.black12,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        widget.thumbnail
                      )
                    )
                  ),
                ),
              ),
            ),
            SizedBox(height: _heightOne * 15,),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _widthOne * 30,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        child: !_isLiked ?
                          SvgPicture.asset(
                            "assets/images/love_icon.svg",
                            width: 20,
                          )
                          :SvgPicture.asset(
                            "assets/images/loved_icon.svg",
                            width: 20,
                          ),
                          onTap: () async{
                              if (!_processing) {
                                _processing = true;
                                if(!_isLiked){

                                  _isLiked = await _userVideoStore.likeVideo(
                                    videoID: widget.id,
                                  );
                                  if(_isLiked){
                                    likeCount += 1;
                                    print("liked");
                                  }
                                }else{
                                  await _userVideoStore.dislikeVideo(
                                    videoID: widget.id,
                                  ).then((value){
                                    if(value){
                                      _isLiked = false;
                                    }
                                  });
                                  if(!_isLiked){
                                    likeCount -= 1;
                                    print("disliked");
                                  }
                                }
                                _processing = false;
                              }
                              setState(() {});print("state");

                            },
                      ),
                      SizedBox(width: _widthOne * 20,),
                      Text(
                        likeCount.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: _fontOne * 14,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: _widthOne * 40,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsScreen(
                                videoId: widget.id,
                              )
                            )
                          );
                        },
                        icon: Icon(
                          Icons.comment,
                          color: Colors.yellow[900],
                          size: _iconOne * 23,
                        ),
                      ),
                      SizedBox(width: _widthOne * 20,),
                      Text(
                        widget.commentCount.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: _fontOne * 14,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: _widthOne * 50,),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackShape: RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbColor: Colors.orange[600],
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 18.0),
                      ),
                      child: Slider(
                        value: _sliderValue,
                        min: 0,
                        max: 5,
                        divisions: 5,
                        onChangeEnd: (val) async {
                          _sliderValue = val;
                          bool success =
                              await _userVideoStore.rateVideo(videoID:widget.id,rating: _sliderValue);
                          if(success){
                            print('done rating');
                          }
                          else{
                            print('failure');
                          }
                          },
                        onChanged: (val) {
                          setState(() {
                            _sliderValue = val;
                          });
                        },
                        inactiveColor: Colors.orange[100],
                        activeColor: Colors.orange[400],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}