import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/core/models/user.dart';
import 'package:fluttershare/ui/custom_widgets/progress.dart';
import 'package:fluttershare/ui/screens/home_screen.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  // StreamSubscription streamSubscription;
  // List<User> allUsers = [];
  // List<User> getFiltered = [];
  //
  // getAllUsers(){
  //   Stream<QuerySnapshot> users = usersRef.snapshots();
  //   streamSubscription = users.listen((event) {
  //     if(event.documents.length < 1){
  //       print("no user found");
  //     }else{
  //       for(int i = 0; i<event.documents.length; i++){
  //         allUsers.add(User.fromJson(event.documents[i].data, event.documents[i].documentID));
  //         // print(event.documents[i].data);
  //       }
  //     }
  //   });
  // }

  handleSearch(String query) {
    // getFiltered = getAllUsers().where((e) => (e.displayName.toLowerCase().contains(query.toLowerCase()))).toList();
    // print(getFiltered.length);
    // setState(() {});
    // getFiltered =
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch(){
    searchController.clear();
  }

  // @override
  // void initState() {
  //   getAllUsers();
  //   super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }

  /// App Bar of the screen
  ///
  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(Icons.account_box,size: 28,),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch
          )
        ),
        onChanged: (value) {
          handleSearch(value);
        },
      ),
    );
  }

  /// Body of the screen ... for not content showing
  ///
  Container buildNoContent(){
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ?  300 : 160,
            ),
            Text('Find User',textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic,fontWeight: FontWeight.w600,fontSize: 55),)
          ],
        ),
      ),
    );
  }

  /// Body of the screen ... in case of showing results for search
  ///
  buildSearchResults(){
    return
      // ListView.builder(
      //   itemCount: getFiltered.length,
      //   itemBuilder: (context, index){
      //     return Container(
      //       color: Theme.of(context).primaryColor.withOpacity(0.7),
      //       child: Column(
      //         children: <Widget>[
      //           GestureDetector(
      //             onTap: () => print('Tapped'),
      //             child: ListTile(
      //               leading: CircleAvatar(
      //                 backgroundColor: Colors.grey,
      //                 backgroundImage: CachedNetworkImageProvider(getFiltered[index].photoUrl),
      //               ),
      //               title: Text(getFiltered[index].displayName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      //               subtitle: Text(getFiltered[index].username, style: TextStyle(color: Colors.white),),
      //             ),
      //           ),
      //           Divider(
      //             height: 2.0,
      //             color: Colors.white54,
      //           )
      //         ],
      //       ),
      //     );
      //   });
      FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print('Tapped'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(user.displayName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              subtitle: Text(user.username, style: TextStyle(color: Colors.white),),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
