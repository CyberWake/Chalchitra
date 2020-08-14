// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wowtalent/auth/auth_api.dart';

// import 'package:wowtalent/notifier/auth_notifier.dart';

// class HomeScreen extends StatelessWidget {
//   // const Home_Screen({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//           title: Text(authNotifier.user != null
//               ? authNotifier.user.displayName
//               : "WowTalent"),
//           backgroundColor: Colors.teal,
//           elevation: 0.0,
//           actions: <Widget>[
//             FlatButton.icon(
//               icon: Icon(Icons.person),
//               label: Text('logout'),
//               onPressed: () => signOut(authNotifier),
//             )
//           ]),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:wowtalent/data/post_json.dart';
// import 'package:wowtalent/theme/colors.dart';
import 'package:wowtalent/widgets/post_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     children: <Widget>[
          //       Padding(
          //         padding:
          //             const EdgeInsets.only(right: 20, left: 15, bottom: 10),
          //         child: Column(
          //           children: <Widget>[
          //             Container(
          //               width: 65,
          //               height: 65,
          //               child: Stack(
          //                 children: <Widget>[
          //                   Container(
          //                     width: 65,
          //                     height: 65,
          //                     decoration: BoxDecoration(
          //                         shape: BoxShape.circle,
          //                         image: DecorationImage(
          //                             image: NetworkImage(profile),
          //                             fit: BoxFit.cover)),
          //                   ),
          //                   Positioned(
          //                       bottom: 0,
          //                       right: 0,
          //                       child: Container(
          //                         width: 19,
          //                         height: 19,
          //                         decoration: BoxDecoration(
          //                             shape: BoxShape.circle, color: black),
          //                         child: Icon(
          //                           Icons.add_circle,
          //                           color: buttonFollowColor,
          //                           size: 19,
          //                         ),
          //                       ))
          //                 ],
          //               ),
          //             ),
          //             SizedBox(
          //               height: 8,
          //             ),
          //             SizedBox(
          //               width: 70,
          //               child: Text(
          //                 name,
          //                 overflow: TextOverflow.ellipsis,
          //                 style: TextStyle(color: black),
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //       Row(
          //           children: List.generate(stories.length, (index) {
          //         return StoryItem(
          //           img: stories[index]['img'],
          //           name: stories[index]['name'],
          //         );
          //       })),
          //     ],
          //   ),
          // ),
          // Divider(
          //   color: black.withOpacity(0.3),
          // ),
          Column(
            children: List.generate(posts.length, (index) {
              return PostItem(
                postImg: posts[index]['postImg'],
                profileImg: posts[index]['profileImg'],
                name: posts[index]['name'],
                caption: posts[index]['caption'],
                isLoved: posts[index]['isLoved'],
                viewCount: posts[index]['commentCount'],
                likedBy: posts[index]['likedBy'],
                dayAgo: posts[index]['dayAgo'],
              );
            }),
          )
        ],
      ),
    );
  }
}
