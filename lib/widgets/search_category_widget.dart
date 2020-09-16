import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/screen/mainScreens/explore/categories.dart';
import 'package:wowtalent/theme/colors.dart';

class CategoryStoryItem extends StatelessWidget {
  final String name;
  const CategoryStoryItem({
    Key key,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        print('adding soon');
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => Category(categoryName: name,)));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: white,
              border: Border.all(color: Colors.orange.shade400)),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 25, top: 10, bottom: 10),
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.orange.shade400,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
