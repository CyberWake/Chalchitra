import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/widgets/customFAB.dart';
import 'package:wowtalent/widgets/post.dart';

class BottomNav extends StatefulWidget {
  int currentIndex;
  Function indexController;
  BottomNav({this.currentIndex, this.indexController});
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(color: AppTheme.primaryColor),
      width: _size.width,
      height: _size.height * 0.08,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF291B2C),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      icon: Icon(
                        widget.currentIndex == 0
                            ? Icons.home
                            : Icons.home_outlined,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                        widget.indexController(0);
                      }),
                  IconButton(
                      icon: Icon(
                        widget.currentIndex == 1
                            ? Icons.explore
                            : Icons.explore_outlined,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                        widget.indexController(1);
                      }),
                  // CustomFAB(),
                  CircleAvatar(
                    radius: 22.0,
                    backgroundColor: AppTheme.secondaryColor,
                    child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () {
                          widget.indexController(2);
                        }),
                  ),
                  IconButton(
                      icon: Icon(
                        widget.currentIndex == 3
                            ? Icons.chat_bubble
                            : Icons.chat_bubble_outline,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                        widget.indexController(3);
                      }),
                  IconButton(
                      icon: Icon(
                        widget.currentIndex == 4
                            ? Icons.person
                            : Icons.person_outline,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                        widget.indexController(4);
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
