import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/core/models/user.dart';
import 'package:fluttershare/ui/custom_widgets/progress.dart';
import 'package:fluttershare/ui/screens/home_screen.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  User user;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool _bioValid = true;
  bool _displayNameValid = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getUser();
    super.initState();
  }
  /// Get user all data in the init state when this page is loaded
  ///
  getUser() async{
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  /// This is for building display name and bio field
  ///
  Column buildNameAndBioField(TextEditingController controller, String hint, String label){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12),
          child: Text(label, style: TextStyle(color: Colors.grey),),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            errorText: _displayNameValid ? _bioValid ? null : 'Bio too long' : 'Display Name too short'
          ),
        )
      ],
    );
  }

  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length < 3 || displayNameController.text.isEmpty ? _displayNameValid = false :
          _displayNameValid = true;
      bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
    });
    if(_displayNameValid && _bioValid){
      usersRef.document(widget.currentUserId).updateData({
        'displayName': displayNameController.text,
        'bio' : bioController.text,
      });
      SnackBar snackBar = SnackBar(content: Text('Profile updated1'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile',style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done,size: 30, color: Colors.green,),
              onPressed: () => Navigator.pop(context)
          )
        ],
      ),
      body: isLoading ? circularProgress() :
          ListView(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                        radius: 50,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          buildNameAndBioField(displayNameController, 'Update Display Name', 'Display Name'),
                          buildNameAndBioField(bioController, 'Update Bio', 'Bio')
                        ],
                      ),
                    ),
                    RaisedButton(
                      onPressed: updateProfileData,
                      child: Text('Update Profile',style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: FlatButton.icon(
                          onPressed: () async{
                            await googleSignIn.signOut();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                          },
                          icon: Icon(Icons.cancel, color: Colors.red,),
                          label: Text('Logout',style: TextStyle(color: Colors.red,fontSize: 20),)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
    );
  }
}
