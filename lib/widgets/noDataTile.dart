import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/mainScreensWrapper.dart';

class NoDataTile extends StatefulWidget {
  final String titleText;
  final String bodyText;
  final String subBodyText;
  final String buttonText;
  final bool showButton;
  final bool isActivity;
  NoDataTile(
      {this.titleText,
      this.bodyText,
      @required this.showButton,
      @required this.isActivity,
      this.buttonText,
      this.subBodyText = " "});
  @override
  _NoDataTileState createState() => _NoDataTileState();
}

class _NoDataTileState extends State<NoDataTile>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Platform.isIOS ? AppTheme.backgroundColor : Colors.transparent,
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
                    text: widget.titleText,
                    style: TextStyle(
                        fontSize: widget.isActivity ? 50 : 56,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.bodyText, //'  Creators to see content',
                    style: TextStyle(
                        fontSize: widget.isActivity ? 28 : 38,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.subBodyText,
                    style: TextStyle(
                        fontSize: 20,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  )
                ])),
                SizedBox(height: 20),
                widget.showButton
                    ? FlatButton(
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
                            widget.buttonText,
                            style: TextStyle(
                                fontSize: 18, color: AppTheme.backgroundColor),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
