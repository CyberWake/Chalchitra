import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wowtalent/model/theme.dart';

class DummyPostCard extends StatelessWidget {
  double _widthOne;
  double _heightOne;
  double _fontOne;
  double _iconOne;
  Size _size;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              height: _size.height * 0.4,
              width: _size.width * 0.9,
              decoration: BoxDecoration(
                color: AppTheme.pureWhiteColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    offset: Offset(0.0, 0.0), //(x,y)
                    blurRadius: 15.0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(_fontOne * 12.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      highlightColor: AppTheme.pureWhiteColor,
                      baseColor: AppTheme.backgroundColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: _widthOne * 140,
                            height: _heightOne * 40,
                            decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          SizedBox(
                            width: _widthOne * 40,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: _heightOne * 20,
                                  width: _widthOne * 300,
                                  color: AppTheme.backgroundColor,
                                ),
                                SizedBox(
                                  height: _heightOne * 1.5,
                                ),
                                Container(
                                  height: _heightOne * 20,
                                  width: _widthOne * 250,
                                  color: AppTheme.backgroundColor,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: _widthOne * 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.more_horiz,
                                  color: Colors.grey, size: _iconOne * 30),
                              Container(
                                height: _heightOne * 15,
                                width: _widthOne * 100,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: _heightOne * 15,
                    ),
                    Expanded(
                      child: Shimmer.fromColors(
                        highlightColor: AppTheme.pureWhiteColor,
                        baseColor: AppTheme.backgroundColor,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomLeft: Radius.circular(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                offset: Offset(0.0, 0.0), //(x,y)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _heightOne * 15,
                    ),
                    Shimmer.fromColors(
                      highlightColor: AppTheme.pureWhiteColor,
                      baseColor: AppTheme.backgroundColor,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: _heightOne * 35,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
