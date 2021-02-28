import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/core/models/user.dart';
import 'package:fluttershare/ui/custom_widgets/progress.dart';
import 'package:fluttershare/ui/screens/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';


class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  /// It will take image Using camera
  ///
  handleTakePhoto() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera,
      maxHeight: 650,
      maxWidth: double.infinity
    );
    setState(() {
      this.file = file;
    });
  }

  /// It will take image from Gallery
  ///
  handleChooseFromGallery() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 650,
        maxWidth: double.infinity
    );
    setState(() {
      this.file = file;
    });
  }

  /// Upload Image button will work using this function
  /// [TakingImage] and [SelectFromGallery]
  selectImage(BuildContext context){
    return showDialog(
        context: context,
      builder: (context){
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handleTakePhoto ,
              ),
              SimpleDialogOption(
                child: Text('Image from gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
      }
    );
  }

  /// <===============> Main [BuildFunction] Here <===============> ///
  ///
  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }

  /// Splash Screen .... Having upload image button
  ///
  Container buildSplashScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg',height: 260,),
          Padding(
              padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Upload Image',style: TextStyle(color: Colors.white,fontSize: 22),),
                ),
                color: Colors.deepOrange,
                onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  /// This fuction will handle [UploadingPosts]  to firestore
  ///
  handleUpload() async{
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      caption: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  /// This function is used to compress image before uploading to firebase
  ///
  compressImage() async{
    final tempDirectory = await getTemporaryDirectory();
    final path = tempDirectory.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  /// This function will [UploadImage] to Firebase Storage and will get it's Url back
  ///
  Future<String> uploadImage(imageFile) async{
    StorageUploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  /// This function will [CreatePost] in Firestore
  ///
  createPostInFirestore({String mediaUrl, String location, String caption}){
    postsRef
      .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'location': location,
      'caption': caption,
      'timestamp': timeStamp,
      'likes': {}
    });
  }

  /// This function will get user location and will show in the field of location
  ///
  getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAdress = '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} '
        '${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, '
        '${placemark.country}';
    print(completeAdress);
    String formatAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formatAddress;
  }

  /// This screen is loaded when we pick image and want to [uploadPost] it to firebase
  ///
  Scaffold buildUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.black,),
            onPressed: (){
              setState(() {
                file = null;
              });
            }
        ),
        title: Text('Caption Post',style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          FlatButton(
              child: Text('Post',style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),),
              onPressed: isUploading ? null : () => handleUpload(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                  aspectRatio: 16 / 9 ,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                        image: FileImage(file)
                    )
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.currentUser.photoUrl,
              ),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'write a caption....',
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop,color: Colors.orange, size: 35,),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                   border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(Icons.my_location,color: Colors.white,),
                label: Text('User Current Location',style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }
}
