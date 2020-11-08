import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';
import 'package:wowtalent/widgets/notificationCard.dart';

class ActivityPage extends StatefulWidget {
  final String uid;
  ActivityPage({this.uid});
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with TickerProviderStateMixin {
  UserInfoStore _userInfoStore = UserInfoStore();

  ParticleOptions particleOptions = ParticleOptions(
    image: Image.asset('assets/images/star_stroke.png'),
    baseColor: Colors.blue,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.1,
    maxOpacity: 0.4,
    spawnMinSpeed: 30.0,
    spawnMaxSpeed: 70.0,
    spawnMinRadius: 15.0,
    spawnMaxRadius: 25.0,
    particleCount: 40,
  );

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  Size _size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.backgroundColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('Activity'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: bodyContent(),
    );
  }

  Widget bodyContent() {
    return Material(
      child: FutureBuilder(
        future: _userInfoStore.getActivityFeed(uid: widget.uid),
        builder: (context, snap) {
          print(snap.data);
          if (snap.connectionState == ConnectionState.waiting ||
              !snap.hasData) {
            return ListView.builder(
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return Shimmer.fromColors(
                    highlightColor: AppTheme.backgroundColor,
                    baseColor: AppTheme.pureWhiteColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(
                            color: AppTheme.primaryColorDark, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                });
          } else if (snap.data.documents.length == 0) {
            return Container(
                color: Colors.transparent,
                child: AnimatedBackground(
                    behaviour: RandomParticleBehaviour(
                      options: particleOptions,
                      paint: particlePaint,
                    ),
                    vsync: this,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(TextSpan(text: '', children: <InlineSpan>[
                              TextSpan(
                                text: 'Your Activity',
                                style: TextStyle(
                                    fontSize: 50,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '\n\nAll your app notifications will show up here.',
                                style: TextStyle(
                                    fontSize: 28,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '\n\nGo engage with Creators: Like, Follow, Comment and Rate their Talent\n',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold),
                              )
                            ])),
                            FlatButton(
                              color: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) => MainScreenWrapper(
                                              index: 1,
                                            )));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2),
                                child: Text(
                                  'Explore Talent',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.secondaryColor),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )));
          }
          return ListView.builder(
            itemCount: snap.data.documents.length,
            itemBuilder: (context, index) {
              return NotificationCard(
                type: snap.data.documents[index]['type'],
                from: snap.data.documents[index]["from"],
                videoId: snap.data.documents[index]['type'] == "follow"
                    ? ""
                    : snap.data.documents[index]['videoID'],
              );
            },
          );
        },
      ),
    );
  }
}
