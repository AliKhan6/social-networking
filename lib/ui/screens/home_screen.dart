import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/core/models/user.dart';
import 'package:fluttershare/ui/screens/activity_feed.dart';
import 'package:fluttershare/ui/screens/create_account.dart';
import 'package:fluttershare/ui/screens/profile.dart';
import 'package:fluttershare/ui/screens/search.dart';
import 'package:fluttershare/ui/screens/timeline_screen.dart';
import 'package:fluttershare/ui/screens/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final DateTime timeStamp = DateTime.now();
final commentsRef = Firestore.instance.collection('comments');
User currentUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    /// Make it in the initState because we need to dispose it when we don't need
    pageController = PageController();
    /// Here we check that user is signed in or not
    ///
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err){
      print('Error signing in $err');
    });
    /// ReAuthenticate user when app is reopened
    ///
    googleSignIn.signInSilently(suppressErrors: false).then((account){
      handleSignIn(account);
    }).catchError((err){
      print('Error Signing in $err');
    });
  }

  /// It will handle [googleSignIn] functionality for first time and for reAuthentication.
  handleSignIn(GoogleSignInAccount account){
    if(account != null){
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    }else{
      setState(() {
        isAuth = false;
      });
    }
  }

  /// This function will store user data from googleSignIn in [usersCollection] firestore
  createUserInFirestore() async{

    // 1) Check if user exists in usersCollection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if(!doc.exists){
      // 2) if the user doesn't exist then take them to create account page
      final username = await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in usersCollection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timeStamp,
      });
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  /// Main Screen Body
  ///
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  /// This area is shown when user is [authenticated]
  ///
  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          TimelineScreen(),
          ActivityFeed(),
          Upload(currentUser: currentUser,),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: (pageIndex){
            pageController.animateToPage(
                pageIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut
            );
          },
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
            BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35,)),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
  }

  /// This area is shown when user is [unAuthenticated]
  ///
  Widget buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Social Networking', style: TextStyle(fontFamily: 'Signatra', fontSize: 60, color: Colors.white),),
            SizedBox(height: 6,),
            GestureDetector(
              onTap: (){
                googleSignIn.signIn();
              },
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
