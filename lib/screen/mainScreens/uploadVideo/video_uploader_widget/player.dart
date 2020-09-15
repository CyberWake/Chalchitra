import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/auth_api.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';

class Player extends StatefulWidget {
  final VideoInfo video;
  Player({Key key, @required this.video}) : super(key: key);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  UserAuth _userAuth = UserAuth();
  VideoPlayerController _controller;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  Size _size;
  double _sliderValue = 0.0;
  UserVideoStore _userVideoStore = UserVideoStore();
  int likeCount = 0;
  int commentCount = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Scaffold(
      body: _controller.value.initialized
          ? Container(
        color: Colors.black,
            child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://images.pexels.com/photos/'
                                  '994605/pexels-photo-994605.jpeg?'
                                  'auto=compress&cs='
                                  'tinysrgb&dpr=2&h=200&w=1260'
                          ),
                          radius: 13,
                        ),
                        Text('  USERNAME \u2022',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        GestureDetector(
                          onTap:(){
                            if(_userAuth.user == null){
                              Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Authentication();
                                  },
                                ),
                              );
                            }
                          },
                          child: Text(' Follow',style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 23,top: 5),
                    child: Row(
                      children: [
                        Icon(Icons.equalizer,color: Colors.white,),
                        Text('  TITLE \u2022',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        Text(' Category',style: TextStyle(color: Colors.white),)
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black12.withOpacity(0.4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                child: SvgPicture.asset(
                                  _isLiked ?
                                  "assets/images/loved_icon.svg":
                                  "assets/images/love_icon.svg",
                                  color: Colors.white,
                                  width: 20,
                                ),
                                onTap: () async {
                                  if(_userAuth.user == null){
                                    Navigator.pushReplacement(context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Authentication();
                                        },
                                      ),
                                    );
                                  }
                                  setState(() {
                                    _isLiked = _isLiked == true ? false:true;
                                    likeCount = _isLiked?likeCount+1:likeCount-1;
                                  });
                                }
                            ),
                            SizedBox(width: _widthOne * 20,),
                            Text(
                              likeCount.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: _fontOne * 14,
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: _widthOne * 30,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: (){
                                if(_userAuth.user == null){
                                  Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Authentication();
                                      },
                                    ),
                                  );
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommentsScreen(
                                          videoId: widget.video.uploaderUid,
                                        )
                                    )
                                );
                              },
                              icon: Icon(
                                Icons.comment,
                                color: Colors.white,
                                size: _iconOne * 23,
                              ),
                            ),
                            SizedBox(width: _widthOne * 20,),
                            Text(
                              commentCount.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: _fontOne * 14,
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: _widthOne * 30,),
                        SizedBox(
                          width: _widthOne * 650,
                          child: Slider(
                            value: _sliderValue,
                            min: 0,
                            max: 5,
                            onChangeEnd: (val){
                              _sliderValue = val;
                            },
                            onChanged: (val) async {
                              if(_userAuth.user == null){
                                Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Authentication();
                                    },
                                  ),
                                );
                              }
                              bool success =
                                  await _userVideoStore.rateVideo(videoID:widget.video.uploaderUid,rating: _sliderValue);
                              if(success){
                                print('done rating');
                              }
                              else{
                                print('failure');
                              }
                              setState(() {
                                _sliderValue = val;
                              });
                            },
                            inactiveColor: Colors.white,
                            activeColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ]
      ),
          )
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}