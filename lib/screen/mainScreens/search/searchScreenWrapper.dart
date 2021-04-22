import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chalchitra/screen/screenImports.dart';
import 'package:Chalchitra/model/modelImports.dart';
import 'package:Chalchitra/database/databaseImports.dart';

class SearchScreenWrapper extends StatefulWidget {
  @override
  _SearchScreenWrapperState createState() => _SearchScreenWrapperState();
}

class _SearchScreenWrapperState extends State<SearchScreenWrapper> with SingleTickerProviderStateMixin {

    final thumbWidth = 100;
  final thumbHeight = 150;
  bool isFound = false;
  var queryResultSet = [];
  var hashtagResultSet = [];
  List<UserDataModel> searchUserResult = [];
  List<VideoInfo> searchHashResult = [];
  String search = "";
  UserInfoStore searchUser = UserInfoStore();
  UserVideoStore searchHash = UserVideoStore();
  SearchResult searchResult;
  QuerySnapshot searchKeyQuery;
  QuerySnapshot hashKeyQuery;
  TextEditingController searchTextEditingController = TextEditingController();
  //Future<QuerySnapshot> futureSearchResult;
  //final ref = FirebaseFirestore.instance.collection('WowUsers');
  UserDataModel user;

  TabController _tabController;
  @override
    void initState() {
      _tabController = TabController(length: 2,vsync: this);
      super.initState();
  }



  initiateHashtagSearch(String hash) async {
    if(hash.length==0){
      setState(() {
              searchHashResult = [];
              hashtagResultSet = [];
      });
    }

    var capitalHash = "#"+hash.toUpperCase();
    if(hashtagResultSet.length==0 &&hash.length==0 || hash.length==1){
      if(hash.length!=0){
        hashKeyQuery = await searchHash.searchByHashtag(hash);
      }
      searchHashResult = [];
      for(int i  =0;i<hashKeyQuery.docs.length;++i){
        hashtagResultSet.add(hashKeyQuery.docs[i].data());
        if(hashKeyQuery.docs[i].data()['videoHashtag'].startsWith(hash)){
          VideoInfo vid = VideoInfo.fromDocument(hashKeyQuery.docs[i]);
          searchHashResult.add(vid);
          setState(() {
            isFound = true;
          });
        }
      }
      if(hashKeyQuery.size==0){
        setState(() {
          isFound = false;
        });
      }

    }else{
      print('running3ad');
      searchHashResult = [];
      for (int i = 0; i < hashKeyQuery.docs.length; ++i) {
        hashtagResultSet.add(hashKeyQuery.docs[i].data());
        if (hashKeyQuery.docs[i]
            .data()['videoHashtag']
            .startsWith(hash)) {
          VideoInfo vid =
              VideoInfo.fromDocument(hashKeyQuery.docs[i]);
          searchHashResult.add(vid);
          if (searchHashResult.length == 0) {
            isFound = false;
          }
          setState(() {});
        }
      }
    }
  }

  initiateSearch(searchUsername) async {
    if (searchUsername.length == 0) {
      setState(() {
        queryResultSet = [];
        searchUserResult = [];
      });
    }

    var capitalizedValue = searchUsername.toUpperCase();

    if (queryResultSet.length == 0 && searchUsername.length == 0 ||
        searchUsername.length == 1) {
      print('running1');
      if (searchUsername.length != 0) {
        searchKeyQuery = await searchUser.searchByUserName(searchUsername);
      }
      searchUserResult = [];
      for (int i = 0; i < searchKeyQuery.docs.length; ++i) {
        queryResultSet.add(searchKeyQuery.docs[i].data());
        if (searchKeyQuery.docs[i]
            .data()['username']
            .toUpperCase()
            .startsWith(capitalizedValue)) {
          UserDataModel eachUser =
              UserDataModel.fromDocument(searchKeyQuery.docs[i]);
          searchUserResult.add(eachUser);
          setState(() {
            isFound = true;
          });
        }
      }
      if (searchKeyQuery.size == 0) {
        setState(() {
          isFound = false;
        });
      }
    } else {
      print('running2');
      searchUserResult = [];
      for (int i = 0; i < searchKeyQuery.docs.length; ++i) {
        queryResultSet.add(searchKeyQuery.docs[i].data());
        if (searchKeyQuery.docs[i]
            .data()['username']
            .toUpperCase()
            .startsWith(capitalizedValue)) {
          UserDataModel eachUser =
              UserDataModel.fromDocument(searchKeyQuery.docs[i]);
          searchUserResult.add(eachUser);
          if (searchUserResult.length == 0) {
            isFound = false;
          }
          setState(() {});
        }
      }
    }
  }

  List<Widget> searchField(){
    return [Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(bottom: 20, left: 15, right: 15),
      height: 70,
      color: AppTheme.primaryColor,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Material(
              type: MaterialType.button,
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              color: Colors.transparent,
              child: TextFormField(
                controller: searchTextEditingController,
                onChanged:_tabController.index==0 ? (String usernameIndex) {
                            if (usernameIndex.length == 0) {
                              searchTextEditingController.clear();
                              searchUserResult = [];
                              search = "";
                              setState(() {
                                searchHashResult = [];
                                searchUserResult = [];
                                search = "";
                                isFound = false;
                              });
                            }
                            print("Username Index: $usernameIndex");
                            initiateSearch(usernameIndex);
                          }:(hash){
                            if(hash.length==0){
                              searchTextEditingController.clear();
                              searchHashResult=[];
                              search="";
                              setState(() {
                                searchHashResult=[];
                                search = "";
                                isFound=false;
                              });
                            }
                            initiateHashtagSearch(hash);
                          },
                decoration: InputDecoration(
                    hintText: "Search by Username",

                    // contentPadding: EdgeInsets.all(10),
                    focusColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.white)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.white)),
                    fillColor: AppTheme.pureWhiteColor,
                    filled: true,
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppTheme.secondaryColor,
                      ),
                      onPressed: () {
                                    searchTextEditingController.clear();
                                    searchUserResult = [];
                                    search = "";
                                    setState(() {});
                                  },
                    )),
              ),
            ),
          ),
        ],
      ),
    )];
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
                return [
                  SliverList(
                      delegate: SliverChildListDelegate(searchField()))
                ];
              },
              body:Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    onTap: (index){
                      _tabController.animateTo(index);
                    },
                    indicatorColor: AppTheme.secondaryColor,
                    labelColor: AppTheme.secondaryColor,
                    unselectedLabelColor: AppTheme.grey,
                    tabs: [
                      Tab(
                        child: Text("People"),
                      ),
                      Tab(
                        child: Text("Hashtags"),
                      )
                    ],
                  ),
                  Expanded(
                      child: TabBarView( 
                        controller: _tabController,
                    children: [
                      // Container(color: Colors.red,),
                      // Container(color: Colors.amber,)
                      Container(
                  child: isFound
                      ? ListView.builder(
                          itemCount: searchUserResult.length,
                          itemBuilder: (BuildContext context, int index) {
                            // print(
                            //     "${user.id}--------------------------------YYYYYYYY-------------------");
                            return SearchResult(searchUserResult[index]);
                          }
                          // tempSearchStore == null ? resultNotFound() : foundUsers(),
                          )
                      : resultNotFound()),
                      Container(
                        child: isFound ? 
                        ListView.builder(
                          itemCount: searchHashResult.length,
                          itemBuilder: (_,index){
                            return GestureDetector(child: SearchHashResult(searchHashResult[index]),onTap: (){
                              Navigator.push(context,CupertinoPageRoute(builder: (_)=>Player(index: index,videos: searchHashResult,)));
                            },);
                          },
                        ):resultNotFound(),
                      )
                    ],
                  ))
                ],
              ), 
          ),
        ),
      ),
    );
  }



  Widget resultNotFound() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.group,
            color: AppTheme.primaryColor,
            size: 40,
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            "Search User",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 25),
          )
        ]);
  }
}



class SearchHashResult extends StatelessWidget {
  final VideoInfo vid;
  SearchHashResult(this.vid);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text("#${vid.videoHashtag}",style: TextStyle(color: AppTheme.secondaryColor),),
        subtitle: Text(vid.category,style: TextStyle(color: AppTheme.secondaryColor)),
        trailing: AspectRatio(
          aspectRatio: vid.aspectRatio,
          child: Image.network(vid.thumbUrl),
          // decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(vid.thumbUrl),fit: BoxFit.fill),),
        )
      ),
    );
  }
}