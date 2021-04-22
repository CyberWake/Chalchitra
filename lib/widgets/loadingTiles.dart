import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Chalchitra/imports.dart';

class LoadingCards extends StatelessWidget {
  final int count;
  LoadingCards({this.count = 8});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.count == 8 ? MediaQuery.of(context).size.height : 90,
      child: ListView.builder(
          itemCount: this.count,
          itemBuilder: (BuildContext context, int index) {
            return Shimmer.fromColors(
              highlightColor: AppTheme.secondaryLoading,
              baseColor: AppTheme.primaryLoading,
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: this.count == 8 ? 15 : 0.0),
                margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                height: this.count == 8 ? 70 : 90,
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
