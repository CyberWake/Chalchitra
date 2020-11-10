import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';

class BouncingButton extends StatefulWidget {
  final bool isLikeButton;
  final Widget likeButton;
  final String buttonText;
  final double width;
  final double height;
  final Function buttonFunction;
  BouncingButton(
      {this.isLikeButton = false,
      this.likeButton,
      this.buttonText = " ",
      this.width,
      this.height = 40.0,
      this.buttonFunction});
  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.4,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTap: () {
        widget.buttonFunction();
      },
      child: Transform.scale(
        scale: _scale,
        child: _animatedButton(),
      ),
    );
  }

  Widget _animatedButton() {
    return widget.isLikeButton
        ? widget.isLikeButton
        : Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 12.0,
                    offset: Offset(0.0, 5.0),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColorDark,
                  ],
                )),
            child: Center(
              child: Text(
                widget.buttonText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.backgroundColor),
              ),
            ),
          );
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }
}
