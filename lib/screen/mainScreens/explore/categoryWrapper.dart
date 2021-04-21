import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/explore/categories.dart';
import 'package:wowtalent/screen/mainScreens/search/search.dart';
import 'package:wowtalent/screen/mainScreens/search/searchScreenWrapper.dart';
import 'package:wowtalent/widgets/categoryWidget.dart';
import 'package:wowtalent/widgets/customTabView.dart';

class CategoryWrapper extends StatefulWidget {
  @override
  _CategoryWrapperState createState() => _CategoryWrapperState();
}

class _CategoryWrapperState extends State<CategoryWrapper>with SingleTickerProviderStateMixin {
  TabController _controller;
  Size _size;

  List<String> searchCategories = [
    "Vocals",
    "Dance",
    "Instrumental",
    "Stand-up Comedy",
    "DJing",
    "Acting",
  ];
  int currentIndex = 0;

  @override
  void initState() {
    _controller = TabController(length: searchCategories.length, vsync: this);
    _controller.index = currentIndex;
    _controller.addListener(() {
      setState(() {

      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          // SizedBox(height: 70),
          Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreenWrapper()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 45,
                        margin: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppTheme.pureWhiteColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_outlined),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Search for creator or hashtag',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          Expanded(
            child: CustomTabView(
              onPositionChange: (index){
                setState(() {
                  currentIndex = index;
                });
              },
              onScroll: (index){
                setState(() {
                  currentIndex = index.toInt();
                });
              },
              itemCount: searchCategories.length,
              pageBuilder: (BuildContext context, int index) {
                return Category(
                  categoryName: searchCategories[index],
                );
              },
              tabBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _controller.animateTo(index);
                  },
                  child: CategoryStoryItem(
                    name: searchCategories[index],
                    selected: index == currentIndex,
                  ),
                );
            },


            ),
          ),
        ],
      ),
    );
  }
}
