import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String title, bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Social Networking' : title,
      style: TextStyle(color: Colors.white,
          fontFamily: isAppTitle ? 'Signatra' : '',
          fontSize: isAppTitle ? 35 : 22,
      ),),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
