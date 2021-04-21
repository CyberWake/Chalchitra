import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/mainScreens/messages/messageSearchResult.dart';

class SearchMessage extends StatefulWidget {
  final String userName;
  SearchMessage({this.userName});
  @override
  _SearchMessageState createState() => _SearchMessageState();
}

class _SearchMessageState extends State<SearchMessage> {
  final thumbWidth = 100;
  final thumbHeight = 150;

  TextEditingController searchTextEditingController = TextEditingController();
  UserDataModel user;
  UserInfoStore _userInfoStore = UserInfoStore();
  List<MessageSearchResult> _searchUserResult = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: foundUsers(),
          )
        ],
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
          SizedBox(width: 20,),
          Text(
            "Search Contacts",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 25
            ),
          )
        ]
    );
  }

  StreamBuilder foundUsers() {
    return StreamBuilder(
        stream: _userInfoStore.getFollowing(
          uid: UserAuth().user.uid
        ),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return LinearProgressIndicator(
              backgroundColor: AppTheme.primaryColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            );
          }
          List uIDs= [];
          dataSnapshot.data.docs.forEach((document) {
            uIDs.add(document.id);
          });
          return FutureBuilder(
            future: getUserDetails(uIDs),
            builder: (context, snapshot){
              if(snapshot.hasData && snapshot.data != null){
                return ListView(
                  children: _searchUserResult,
                );
              }else{
                return Container();
              }
            },
          );
        });
  }

  Future getUserDetails(List uIDs) async{
    try{
      List<MessageSearchResult> searchUserResult = [];
      for(int i = 0; i < uIDs.length; i++){
        DocumentSnapshot documentSnapshot=
        await _userInfoStore.getUserInfo(
            uid: uIDs[i]
        );
        UserDataModel eachUser = UserDataModel.fromDocument(documentSnapshot);
        if(eachUser.username.contains(widget.userName)){
          MessageSearchResult searchResult = MessageSearchResult(eachUser);
          searchUserResult.add(searchResult);
        }
      }
      if(searchUserResult.isNotEmpty){
        _searchUserResult = searchUserResult;
      }
      return "success";
    }catch(e){
      return null;
    }
  }

}