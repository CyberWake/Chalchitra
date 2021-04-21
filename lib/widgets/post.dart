import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';

class Post extends StatelessWidget {
  const Post({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.add_a_photo_outlined,
                  size: 30.0,
                  color: Colors.white70,
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onTap: () {
                  print('Navigate to camera page');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera_back,
                  size: 30.0,
                  color: Colors.white70,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  print('Navigate to gallery page');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
