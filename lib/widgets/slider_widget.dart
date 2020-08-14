import 'package:flutter/material.dart';

class RatingSlider extends StatefulWidget {
  RatingSlider({Key key}) : super(key: key);

  @override
  _RatingSliderState createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider> {
  int initialValue = 0;
  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0,
      max: 100,
      divisions: 5,
      value: initialValue.toDouble(),
      onChanged: (double newValue) {
        setState(() {
          initialValue = newValue.round();
        });
      },
      activeColor: Colors.red,
      inactiveColor: Colors.grey,
    );
  }
}
