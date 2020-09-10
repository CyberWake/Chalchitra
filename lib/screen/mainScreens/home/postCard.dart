import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wowtalent/database/firebase_provider.dart';

class PostCard extends StatefulWidget {
  final String title, uploadTime, thumbnail, profileImg, uploader, id;
  final int commentCount, likeCount, viewCount;
  final int rating;

  PostCard({
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
  bool _isLiked;

  void setup() async{
    _isLiked = await _userVideoStore.checkLiked(
      videoID: widget.id
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = double.parse(widget.rating.toString());
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
                    Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                      size: _iconOne * 20
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      widget.thumbnail
                    )
                  )
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
                      !_isLiked ? InkWell(
                        child: SvgPicture.asset(
                          "assets/images/love_icon.svg",
                          width: 20,
                        ),
                        onTap: () async{
                         await _userVideoStore.likeVideo(
                            videoID: widget.id,
                          );
                        },
                      ) : InkWell(
                        child: SvgPicture.asset(
                          "assets/images/loved_icon.svg",
                          width: 20,
                        ),
                        onTap: () async{
                          await _userVideoStore.dislikeVideo(
                            videoID: widget.id,
                          );
                        },
                      ),
                      SizedBox(width: _widthOne * 20,),
                      Text(
                        widget.likeCount.toString(),
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
                      Icon(
                        Icons.comment,
                        color: Colors.yellow[900],
                        size: _iconOne * 23,
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
                  SizedBox(width: _widthOne * 40,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.blueAccent,
                        size: _iconOne * 23,
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
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      min: 0,
                      max: 5,
                      onChanged: (val){
                        setState(() {
                          _sliderValue = val;
                        });
                      },
                      inactiveColor: Colors.orange[100],
                      activeColor: Colors.orange[400],
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
