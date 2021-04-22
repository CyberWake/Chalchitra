import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/imports.dart';

class CategoryStoryItem extends StatelessWidget {
  final String name;
  final bool selected;
  const CategoryStoryItem({
    Key key,
    this.name,
    this.selected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(right: 10),
          height: MediaQuery.of(context).size.height * 0.05,
          //width: MediaQuery.of(context).size.width * 0.2,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected?AppTheme.pureWhiteColor :AppTheme.primaryColor,
            border: Border.all(
              color: AppTheme.pureWhiteColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color:selected? AppTheme.primaryColor : AppTheme.pureWhiteColor,
                fontWeight: selected?FontWeight.w600:FontWeight.w300,
                fontSize: 16,
              ),
            ),
          ),
        );
  }
}
