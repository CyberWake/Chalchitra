// import 'dart:io';

// import 'package:animations/animations.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:wowtalent/auth/userAuth.dart';
// import 'package:wowtalent/database/userInfoStore.dart';
// import 'package:wowtalent/database/userVideoStore.dart';
// import 'package:wowtalent/model/theme.dart';
// import 'package:wowtalent/model/userDataModel.dart';
// import 'package:wowtalent/model/videoInfoModel.dart';
// import 'package:wowtalent/screen/mainScreens/search/search.dart';
// import 'package:wowtalent/screen/mainScreens/uploadVideo/videoPlayer/player.dart';
// import 'package:wowtalent/widgets/categoryWidget.dart';
// import 'package:wowtalent/widgets/videoCardPlaceHolder.dart';

// class Explore extends StatefulWidget {
//   @override
//   _ExploreState createState() => _ExploreState();
// }

// class _ExploreState extends State<Explore> {
//   final thumbWidth = 100;
//   final thumbHeight = 150;
//   double staggeredHeight = 200.0;
//   double heightIndex1;
//   double heightIndex2;
//   double heightIndex3;
//   Size _size;
//   UserAuth _userAuth = UserAuth();
//   UserDataModel _user = UserDataModel();
//   UserInfoStore _userInfoStore = UserInfoStore();
//   String username = '';
//   String url = '';

//   List<VideoInfo> _allVideos = <VideoInfo>[];
//   List<VideoInfo> _videosTrending = <VideoInfo>[];
//   List<UserDataModel> _userInfo = <UserDataModel>[];
//   List searchCategories = [
//     "Vocals",
//     "Dance",
//     "Instrumental",
//     "Stand-up Comedy",
//     "DJing",
//     "Acting",
//   ];
//   List<IconData> searchIcons = [
//     Icons.mic,
//     Icons.directions_run,
//     Icons.music_note,
//     Icons.sentiment_very_satisfied,
//     Icons.headset,
//     Icons.face,
//   ];

//   setup() {
//     UserVideoStore.listenToAllVideos((newVideos) async {
//       DocumentSnapshot user =
//           await _userInfoStore.getUserInfo(uid: newVideos.uploaderUid);
//       _user = UserDataModel.fromDocument(user);
//       if (this.mounted) {
//         setState(() {
//           _allVideos = newVideos;
//           _userInfo.add(UserDataModel.fromDocument(user));
//         });
//       }
//     });
//     UserVideoStore.listenTopVideos((newVideos) {
//       if (this.mounted) {
//         setState(() {
//           _videosTrending = newVideos;
//         });
//       }
//     });
//   }

//   increaseTrendingWatchCount(int index) async {
//     bool isWatched = await UserVideoStore()
//         .checkWatched(videoID: _videosTrending[index].videoId);
//     if (!isWatched) {
//       await UserVideoStore()
//           .increaseVideoCount(videoID: _videosTrending[index].videoId);
//     }
//   }

//   increaseAllVideoWatchCount(int index) async {
//     bool isWatched =
//         await UserVideoStore().checkWatched(videoID: _allVideos[index].videoId);
//     if (!isWatched) {
//       await UserVideoStore()
//           .increaseVideoCount(videoID: _allVideos[index].videoId);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     setup();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _size = MediaQuery.of(context).size;
//     return SafeArea(child: _videos());
//   }

//   Widget _videos() {
//     return Container(
//       color: AppTheme.secondaryColor,
//       padding: EdgeInsets.only(top: 10),
//       child: Expanded(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 40),
//               // Center(
//               //   child: GestureDetector(
//               //     onTap: () {
//               //       Navigator.push(context,
//               //           MaterialPageRoute(builder: (context) => SearchUser()));
//               //     },
//               //     child: Container(
//               //       width: MediaQuery.of(context).size.width - 40,
//               //       height: 45,
//               //       margin: EdgeInsets.symmetric(vertical: 20),
//               //       decoration: BoxDecoration(
//               //         borderRadius: BorderRadius.circular(10.0),
//               //         color: AppTheme.pureWhiteColor,
//               //       ),
//               //       child: Row(
//               //         mainAxisAlignment: MainAxisAlignment.center,
//               //         children: [
//               //           Icon(Icons.search_outlined),
//               //           SizedBox(
//               //             width: 10.0,
//               //           ),
//               //           Text(
//               //             'Search for creator or hashtag',
//               //             style: TextStyle(
//               //               fontSize: 17.0,
//               //               fontWeight: FontWeight.w500,
//               //             ),
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // ),

//               SizedBox(height: 75),
//               Container(
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "#TrendingNow",
//                 style: TextStyle(
//                   color: AppTheme.secondaryColor,
//                   fontFamily: 'League Spartan',
//                   fontWeight: FontWeight.normal,
//                   letterSpacing: 1.0,
//                   fontSize: 21,
//                 ),
//               ),
//             ),
//             _trendingVideos(),
//             Container(
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "#JudgePicks",
//                 style: TextStyle(
//                   color: AppTheme.secondaryColor,
//                   fontFamily: 'League Spartan',
//                   fontWeight: FontWeight.normal,
//                   letterSpacing: 1.0,
//                   fontSize: 21,
//                 ),
//               ),
//             ),
//             // _staffPicks(),
//             _trendingVideos(),
//             Container(
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "#TalentOnFire",
//                 style: TextStyle(
//                   color: AppTheme.secondaryColor,
//                   fontFamily: 'League Spartan',
//                   fontWeight: FontWeight.normal,
//                   fontSize: 21,
//                 ),
//               ),
//             ),
//             // _latestVideos(),
//             _trendingVideos(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _scrollVideo() {
//   //   return SingleChildScrollView(
//   //     child: Column(
//   //       children: [
//   //         Container(
//   //           alignment: Alignment.centerLeft,
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Text(
//   //             "#TrendingNow",
//   //             style: TextStyle(
//   //               color: AppTheme.secondaryColor,
//   //               fontFamily: 'League Spartan',
//   //               fontWeight: FontWeight.normal,
//   //               letterSpacing: 1.0,
//   //               fontSize: 21,
//   //             ),
//   //           ),
//   //         ),
//   //         _trendingVideos(),
//   //         Container(
//   //           alignment: Alignment.centerLeft,
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Text(
//   //             "#JudgePicks",
//   //             style: TextStyle(
//   //               color: AppTheme.secondaryColor,
//   //               fontFamily: 'League Spartan',
//   //               fontWeight: FontWeight.normal,
//   //               letterSpacing: 1.0,
//   //               fontSize: 21,
//   //             ),
//   //           ),
//   //         ),
//   //         _staffPicks(),
//   //         Container(
//   //           alignment: Alignment.centerLeft,
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Text(
//   //             "#TalentOnFire",
//   //             style: TextStyle(
//   //               color: AppTheme.secondaryColor,
//   //               fontFamily: 'League Spartan',
//   //               fontWeight: FontWeight.normal,
//   //               fontSize: 21,
//   //             ),
//   //           ),
//   //         ),
//   //         _latestVideos(),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Widget _metaInfo(String picUrl, String name) {
//   //   // getUserInfo(video);
//   //   return Row(
//   //     children: [
//   //       CircleAvatar(
//   //         backgroundImage: NetworkImage(
//   //             picUrl == null ? "https://via.placeholder.com/150" : picUrl),
//   //         //: _user.photoUrl),
//   //         radius: 13,
//   //       ),
//   //       Text(
//   //         '  $name \u2022',
//   //         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // Widget _categories() {
//   //   return Container(
//   //     width: _size.width,
//   //     height: _size.height * 0.07,
//   //     child: ListView(
//   //       scrollDirection: Axis.horizontal,
//   //       children: <Widget>[
//   //         Padding(
//   //           padding: const EdgeInsets.only(left: 15),
//   //           child: Row(
//   //             children: List.generate(searchCategories.length, (index) {
//   //               return CategoryStoryItem(
//   //                 name: searchCategories[index],
//   //               );
//   //             }),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _trendingVideos() {
//     return Container(
//       width: _size.width,
//       height: _size.height * 0.25,
//       margin: EdgeInsets.all(5),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         children: List.generate(_videosTrending.length, (index) {
//           final video = _videosTrending[index];
//           // getUserInfo(_videosTrending[index]);
//           // final pic = url;
//           // final name = username;
//           return FittedBox(
//             fit: BoxFit.fill,
//             child: OpenContainer(
//               closedElevation: 0.0,
//               closedColor: Colors.transparent,
//               closedShape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.zero,
//               ),
//               transitionDuration: Duration(milliseconds: 200),
//               transitionType: ContainerTransitionType.fadeThrough,
//               openBuilder: (BuildContext context,
//                   void Function({Object returnValue}) action) {
//                 increaseTrendingWatchCount(index);
//                 return Player(
//                   videos: _videosTrending,
//                   index: index,
//                 );
//               },
//               closedBuilder: (BuildContext context, void Function() action) {
//                 return Stack(
//                   children: [
//                     CachedNetworkImage(
//                       imageUrl: video.thumbUrl,
//                       imageBuilder: (context, imageProvider) => Container(
//                         width: _size.width * 0.65,
//                         height: _size.height * 0.25,
//                         margin: EdgeInsets.all(7),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: AppTheme.secondaryColor,
//                           ),
//                           color: AppTheme.pureBlackColor,
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppTheme.primaryColor.withOpacity(0.2),
//                               offset: Offset(0.0, 10.0), //(x,y)
//                               blurRadius: 10.0,
//                             ),
//                           ],
//                           image: DecorationImage(
//                               image: imageProvider, fit: BoxFit.fitWidth),
//                         ),
//                       ),
//                       placeholder: (context, url) => DummyVideoCard(
//                         width: _size.width * 0.65,
//                         height: _size.height * 0.25,
//                       ),
//                       errorWidget: (context, url, error) => Icon(Icons.error),
//                     ),
//                     // Positioned(
//                     //   child: _metaInfo(pic, name),
//                     //   bottom: 16,
//                     //   left: 15,
//                     // ),
//                   ],
//                 );
//               },
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _search() {
//     return OpenContainer(
//       closedElevation: 0.0,
//       closedColor: AppTheme.primaryColor,
//       tappable: true,
//       transitionDuration: Duration(milliseconds: 500),
//       openBuilder:
//           (BuildContext context, void Function({Object returnValue}) action) {
//         return SearchUser();
//       },
//       closedBuilder: (BuildContext context, void Function() action) {
//         return Icon(
//           Icons.search,
//           color: AppTheme.backgroundColor,
//           size: 30,
//         );
//       },
//     );
//   }

//   Widget _staffPicks() {
//     return Container(
//       width: _size.width,
//       height: _size.height * 0.25,
//       margin: EdgeInsets.all(7),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         children: List.generate(_allVideos.length, (index) {
//           final video = _allVideos[index];
//           return FittedBox(
//             child: OpenContainer(
//               closedElevation: 0.0,
//               closedColor: Colors.transparent,
//               closedShape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.zero,
//               ),
//               transitionDuration: Duration(milliseconds: 200),
//               transitionType: ContainerTransitionType.fadeThrough,
//               openBuilder: (BuildContext context,
//                   void Function({Object returnValue}) action) {
//                 increaseAllVideoWatchCount(index);
//                 return Player(
//                   videos: _allVideos,
//                   index: index,
//                 );
//               },
//               closedBuilder: (BuildContext context, void Function() action) {
//                 return CachedNetworkImage(
//                   imageUrl: video.thumbUrl,
//                   fit: BoxFit.fill,
//                   imageBuilder: (context, imageProvider) => Container(
//                     width: _size.width * 0.65,
//                     height: _size.height * 0.25,
//                     margin: EdgeInsets.all(7),
//                     decoration: BoxDecoration(
//                       // borderRadius: BorderRadius.circular(10.5),
//                       border: Border.all(
//                         color: AppTheme.secondaryColor,
//                       ),
//                       color: AppTheme.pureBlackColor,
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.primaryColor.withOpacity(0.2),
//                           offset: Offset(0.0, 10.0), //(x,y)
//                           blurRadius: 10.0,
//                         ),
//                       ],
//                       image: DecorationImage(
//                           image: imageProvider, fit: BoxFit.fitWidth),
//                     ),
//                   ),
//                   placeholder: (context, url) => DummyVideoCard(
//                     width: _size.width * 0.65,
//                     height: _size.height * 0.25,
//                   ),
//                   errorWidget: (context, url, error) => Icon(Icons.error),
//                 );
//               },
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _latestVideos() {
//     return Container(
//       width: _size.width,
//       padding: EdgeInsets.symmetric(horizontal: 5),
//       child: StaggeredGridView.countBuilder(
//         physics: NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         crossAxisCount: 3,
//         itemCount: _allVideos.length,
//         itemBuilder: (BuildContext context, int index) {
//           dynamic video = _allVideos[index];
//           return GestureDetector(
//             onTap: () async {
//               increaseAllVideoWatchCount(index);
//               Navigator.push(
//                 context,
//                 Platform.isIOS
//                     ? CupertinoPageRoute(builder: (context) {
//                         return Player(
//                           videos: _allVideos,
//                           index: index,
//                         );
//                       })
//                     : MaterialPageRoute(
//                         builder: (context) {
//                           return Player(
//                             videos: _allVideos,
//                             index: index,
//                           );
//                         },
//                       ),
//               );
//             },
//             child: CachedNetworkImage(
//               imageUrl: video.thumbUrl,
//               imageBuilder: (context, imageProvider) => Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey, width: 1),
//                   image:
//                       DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                 ),
//               ),
//               placeholder: (context, url) => Shimmer.fromColors(
//                 highlightColor: AppTheme.pureWhiteColor,
//                 baseColor: AppTheme.grey,
//                 child: Container(
//                   margin: EdgeInsets.all(7),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey, width: 1),
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Icon(Icons.error),
//             ),
//           );
//         },
//         staggeredTileBuilder: (int index) {
//           return StaggeredTile.count(1, 1 / _allVideos[index].aspectRatio);
//         },
//         mainAxisSpacing: 5.0,
//         crossAxisSpacing: 5.0,
//       ),
//     );
//   }
// }
