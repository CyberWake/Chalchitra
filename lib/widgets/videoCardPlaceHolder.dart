import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/model/theme.dart';

class DummyVideoCard extends StatelessWidget {
  final double height;
  final double width;
  DummyVideoCard({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: AppTheme.pureWhiteColor,
      baseColor: AppTheme.grey,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.5),
          color: AppTheme.pureBlackColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              offset: Offset(0.0, 10.0), //(x,y)
              blurRadius: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
