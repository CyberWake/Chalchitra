import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          color: Colors.white,
          child: Center(
            child: SpinKitChasingDots(
              color: Colors.black,
              size: 50.0,
            ),
          )),
    );
  }
}
