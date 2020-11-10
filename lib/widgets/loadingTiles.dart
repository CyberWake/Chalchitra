import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/model/theme.dart';

class LoadingCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: 8,
          itemBuilder: (BuildContext context, int index) {
            return Shimmer.fromColors(
              highlightColor: AppTheme.backgroundColor,
              baseColor: AppTheme.pureWhiteColor,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border:
                      Border.all(color: AppTheme.primaryColorDark, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
    );
  }
}
