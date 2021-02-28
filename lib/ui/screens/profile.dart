import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/core/models/user.dart';
import 'package:fluttershare/ui/custom_widgets/header.dart';
import 'package:fluttershare/ui/custom_widgets/post_tile.dart';
import 'package:fluttershare/ui/custom_widgets/progress.dart';
import 'package:fluttershare/ui/screens/edit_profile.dart';
import 'package:fluttershare/ui/screens/home_screen.dart';
import 'package:fluttershare/ui/screens/posts_screen.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  String postOrientation = 'grid';
  bool isLoading = false;
  int postCount = 0;
  List<PostsScreen> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  /// This function will get posts when profile page is loaded
  ///
  getProfilePost() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef.document(widget.profileId).collection('userPosts').orderBy('timestamp', descending: true).getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => PostsScreen.fromDocument(doc)).toList();
    });
  }

  /// this function will make all counting widgets e.g [posts], [followers], [following]
  ///
  Column buildCountColumn(String label, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(count.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(label,style: TextStyle(color: Colors.grey, fontSize: 15,fontWeight: FontWeight.w400),),
        )
        
      ],
    );
  }

  /// Edit profile function
  editProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfile(currentUserId: currentUserId)));
  }

  /// This button will be follow and unFollow in case of other users and editProfile in case of own profile
  ///
  Container buildButton({String text, Function function}){
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200,
          height: 30,
          child: Text(text,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.blue)
          ),
        ),
      ),
    );
  }

  /// This function is used 1st for [editProfile] and 2nd for
  buildProfileButton(){
    // check if viewing you own profile --- then show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(
        text: 'Edit Profile',
        function: editProfile
      );
    }

  }

  /// Profile header is here
  /// mean first half screen
  ///
  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
            padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", postCount),
                            buildCountColumn("followers", 0),
                            buildCountColumn("following", 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12),
                child: Text(user.username,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4 ),
                child: Text(user.displayName,style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2),
                child: Text(user.bio),
              ),
            ],
          ),
        );
      },
    );
  }

  /// this function will build all posts related to a profile
  ///
  buildProfilePost(){
    if(isLoading){
      return circularProgress();
    } else if(posts.isEmpty){
      /// Splash Screen .... in case of no post....
      ///
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset('assets/images/no_content.svg',height: 260,),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('No Posts',style: TextStyle(fontSize: 40, color: Colors.redAccent,fontWeight: FontWeight.bold),)
              ),
            ],
          ),
        );
    }
    else if(postOrientation == 'grid'){
      List<GridTile> gridTile = [];
      posts.forEach((post) {
        gridTile.add(GridTile(child: PostTile(post: post,),));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,

      );
    } else if(postOrientation == 'list'){
      return Column(
        children: posts,
      );
    }
  }

  /// This function is used to make [gridView] and [lisView] of the post and to [Toggle] between them
  ///
  buildTogglePostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on,color: postOrientation == 'grid' ? Theme.of(context).primaryColor : Colors.grey,),
          onPressed: (){
            setState(() {
              postOrientation = 'grid';
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.list, color: postOrientation == 'list' ? Theme.of(context).primaryColor : Colors.grey,),
          onPressed: (){
            setState(() {
              postOrientation = 'list';
            });
          },
        )
      ],
    );
  }

  /// <===============> Main [BuildFunction] Here <===============> ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(height: 0.0,),
          buildProfilePost(),
        ],
      ),
    );
  }
}
