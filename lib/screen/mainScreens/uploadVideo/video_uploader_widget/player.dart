/*
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/widgets/slider_widget.dart';

class Player extends StatefulWidget {
  final VideoInfo video;
  const Player({Key key, @required this.video}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  String _error;

  @override
  Widget build(BuildContext context) {
    print(widget.video.videoUrl);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _error == null
              ? NetworkPlayerLifeCycle(widget.video.videoUrl,
                  (BuildContext context, VideoPlayerController controller) {
                  return ListView(children: [
                    AspectRatioVideo(controller),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/images/loved_icon.svg",
                                width: 27,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              SvgPicture.asset(
                                "assets/images/comment_icon.svg",
                                width: 27,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              SvgPicture.asset(
                                "assets/images/share_icon.svg",
                                width: 27,
                              ),
                            ],
                          ),
                          RatingSlider()
                          // SvgPicture.asset(
                          //   "assets/images/save_icon.svg",
                          //   width: 27,
                          // ),
                        ],
                      ),
                    ),
                  ]);
                })
              : Center(
                  child: Text(_error),
                ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayPause extends StatefulWidget {
  VideoPlayPause(this.controller);

  final VideoPlayerController controller;

  @override
  State createState() {
    return _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  _VideoPlayPauseState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.setVolume(1.0);
    controller.play();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: VideoPlayer(controller),
        onTap: () {
          if (!controller.value.initialized) {
            return;
          }
          if (controller.value.isPlaying) {
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
            controller.pause();
          } else {
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
            controller.play();
          }
        },
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      ),
      Center(child: imageFadeAnim),
      Center(
          child: controller.value.isBuffering
              ? const CircularProgressIndicator()
              : null),
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }
}

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, value: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    if (animationController != null) animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

abstract class PlayerLifeCycle extends StatefulWidget {
  PlayerLifeCycle(this.dataSource, this.childBuilder);

  final VideoWidgetBuilder childBuilder;
  final String dataSource;
}

/// A widget connecting its life cycle to a [VideoPlayerController] using
/// a data source from the network.
class NetworkPlayerLifeCycle extends PlayerLifeCycle {
  NetworkPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _NetworkPlayerLifeCycleState createState() => _NetworkPlayerLifeCycleState();
}

abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  VideoPlayerController controller;

  @override

  /// Subclasses should implement [createVideoPlayerController], which is used
  /// by this method.
  void initState() {
    super.initState();
    controller = createVideoPlayerController();
    controller.addListener(() {
      if (controller.value.hasError) {
        setState(() {});
      }
    });
    controller.initialize();
    controller.setLooping(true);
    controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }

  VideoPlayerController createVideoPlayerController();
}

class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return VideoPlayerController.network(widget.dataSource);
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.initialized) {
        initialized = controller.value.initialized;
        if (mounted) {
          setState(() {});
        }
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(controller.value.errorDescription,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayPause(controller),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
*/
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';

class Player extends StatefulWidget {
  final VideoInfo video;
  Player({Key key, @required this.video}) : super(key: key);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
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
    Size size = MediaQuery.of(context).size;
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
                          backgroundImage: NetworkImage('https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260'),
                          radius: 13,
                        ),
                        Text('  USERNAME \u2022',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        GestureDetector(
                          onTap:(){

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
                  /*FloatingActionButton(
                    backgroundColor: Colors.grey,
                    elevation: 0.0,
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),*/
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
                                  _isLiked?"assets/images/loved_icon.svg":"assets/images/love_icon.svg",
                                  color: Colors.white,
                                  width: 20,
                                ),
                                onTap: () async {
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
                            onChangeEnd: (val) async {
                              _sliderValue = val;
                              bool success =
                              await _userVideoStore.rateVideo(videoID:widget.video.uploaderUid,rating: _sliderValue);
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