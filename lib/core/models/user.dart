import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String displayName;
  String email;
  String photoUrl;
  String bio;

  User({this.id, this.username, this.displayName, this.email, this.photoUrl, this.bio});

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
        id: doc['id'],
        username: doc['username'],
        displayName: doc['displayName'],
        email: doc['email'],
        photoUrl: doc['photoUrl'],
        bio: doc['bio']
    );
  }

  User.fromJson(Map<String, dynamic> json, id) {
    username = json['body'];
    displayName = json['createdAt'];
    email = json['createdBy'];
    photoUrl = json['tag'];
    bio = json['title'];
    this.id = id;
  }
}