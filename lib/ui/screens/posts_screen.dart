import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/core/models/user.dart';
import 'package:fluttershare/ui/custom_widgets/custom_image.dart';
import 'package:fluttershare/ui/custom_widgets/progress.dart';
import 'package:fluttershare/ui/screens/comments.dart';
import 'package:fluttershare/ui/screens/home_screen.dart';

class PostsScreen extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  final dynamic likes;

  PostsScreen({this.postId, this.ownerId, this.username, this.location, this.caption, this.mediaUrl, this.likes});

  factory PostsScreen.fromDocument(DocumentSnapshot doc){
    return PostsScreen(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      caption: doc['caption'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes){
    // no likes... return zero
    if(likes == null){
      return 0;
    }
    // if the key is explicitly set to true, add a like
    int count = 0;
    likes.values.forEach((val){
      if(val == true){
        count+=1;
      }
    });
    return count;
  }
  @override
  _PostsScreenState createState() => _PostsScreenState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    caption: this.caption,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),
  );
}

class _PostsScreenState extends State<PostsScreen> {
  final String userId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  _PostsScreenState({this.postId, this.ownerId, this.username, this.location, this.caption, this.mediaUrl, this.likes, this.likeCount});

  /// This function will make post header ...
  ///
  buildPostHeader(){
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
         return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print('tapped'),
            child: Text(user.username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => print('aaa'),
            icon: Icon(Icons.more_vert),
          ),
        )  ;
      },
    );
  }

  /// This function will handle liking post ... When post is liked by any user
  ///
  handleLikePost(){
    bool _isLiked = likes[userId] == true;
    if(_isLiked){
      postsRef.document(userId).collection('userPosts').document(postId).updateData(
          {'likes.$userId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[userId] = false;
      });
    }else if(!isLiked){
      postsRef.document(userId).collection('userPosts').document(postId).updateData(
          {'likes.$userId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        showHeart = true;
        likes[userId] = true;
      });
      Timer(Duration(milliseconds: 500),(){
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  /// This function will make image of post
  ///
  buildPostImage(){
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart ?
          Animator<double>(
            duration: Duration(milliseconds: 500),
            tween: Tween<double>(begin: 0.7, end: 1.5),
            cycles: 0,
            builder: (context, animatorState, child ) => Transform.scale(
                scale: animatorState.value,
              child: Icon(Icons.favorite, size: 80, color: Colors.red,),
            )
          ) : Text(''),
        ],
      ),
    );
  }

  /// This is for making post footer having likes and comments
  ///
  buildPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40,left: 20),),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,color: Colors.pink,),
            ),
            Padding(padding: EdgeInsets.only(top: 40,right: 20),),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                  Comments(
                    postId: postId,
                    ownerId: ownerId,
                    mediaUrl: mediaUrl,
                  ),
                )),
              child: Icon(Icons.chat,size: 20,color: Colors.blue[900],),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("$likeCount likes",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("$username",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ),
            Expanded(
                child: Text(caption)
            )
          ],
        ),
        SizedBox(height: 30,)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[userId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
