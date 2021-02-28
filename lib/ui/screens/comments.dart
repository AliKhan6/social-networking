import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/ui/custom_widgets/header.dart';
import 'package:fluttershare/ui/screens/home_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String mediaUrl;
  Comments({this.postId, this.ownerId, this.mediaUrl});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId, ownerId: this.ownerId, mediaUrl: this.mediaUrl
  );
}

class CommentsState extends State<Comments> {
  TextEditingController commentsController = TextEditingController();
  final String postId;
  final String ownerId;
  final String mediaUrl;
  CommentsState({this.postId, this.ownerId, this.mediaUrl});

  addComment(){
    try{
      commentsRef
          .document(postId)
          .collection('comments')
          .add({
        "username" : currentUser.username,
        "comment" : commentsController.text,
        "timestamp" : timeStamp,
        "avatarUrl" : currentUser.photoUrl,
        "userId": currentUser.id,
      });
    }catch(e){
      print("@error adding comment => ${e.toString()}");
    }
    commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Comments"),
      body: Column(
        children: [
          Expanded(
             child: StreamBuilder(
               stream: commentsRef.document(postId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
               builder: (context, snapshot){
                 if(!snapshot.hasData){
                   return CircularProgressIndicator();
                 }else{
                   List<Comment> comments = [];
                   snapshot.data.documents.forEach((doc){
                     comments.add(Comment.fromDocument(doc));
                   });
                   return ListView(
                     children: comments,
                   );
                 }
               },
             ),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentsController,
              decoration: InputDecoration(hintText: 'Write a comment...',border: InputBorder.none),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
      ],
    ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  Comment({this.username, this.userId, this.avatarUrl, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate() )),
        )
      ],
    );
  }
}
