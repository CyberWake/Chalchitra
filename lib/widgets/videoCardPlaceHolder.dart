import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Chalchitra/imports.dart';

class DummyVideoCard extends StatelessWidget {
  final double height;
  final double width;
  DummyVideoCard({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: AppTheme.secondaryLoading,
      baseColor: AppTheme.primaryLoading,
      child: Stack(
        children: [
          Container(
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
          Positioned(
            child: Container(
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
              child: Row(
                children: [
                  Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 30,
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottom: 32,
            left: 20,
          ),
        ],
      ),
    );
  }
}

Widget _metaInfo() {
  return Row(
    children: [
      Container(
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          radius: 30,
        ),
      ),
      SizedBox(width: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    ],
  );
}
