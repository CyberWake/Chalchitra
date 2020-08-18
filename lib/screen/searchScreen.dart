import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wowtalent/theme/colors.dart';
import 'package:wowtalent/data/search_json.dart';
import 'package:wowtalent/widgets/search_category_widget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        SafeArea(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 15,
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                width: size.width - 30,
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: "Search.....",
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Hexcolor('#F23041'),
                      )),
                  style: TextStyle(color: black.withOpacity(0.3)),
                  cursorColor: Hexcolor('#F23041').withOpacity(0.3),
                ),
              ),
              SizedBox(
                width: 15,
              )
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
                children: List.generate(searchCategories.length, (index) {
              return CategoryStoryItem(
                name: searchCategories[index],
              );
            })),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Wrap(
          spacing: 1,
          runSpacing: 1,
          children: List.generate(searchImages.length, (index) {
            return Container(
              width: (size.width - 3) / 3,
              height: (size.width - 3) / 3,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(searchImages[index]),
                      fit: BoxFit.cover)),
            );
          }),
        )
      ],
    ));
  }
}
