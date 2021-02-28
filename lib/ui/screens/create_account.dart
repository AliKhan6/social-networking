import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttershare/ui/custom_widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit(){
    FormState form = _formKey.currentState;
    if(form.validate()){
      form.save();
      SnackBar snackBar = SnackBar(content: Text('Welcome $username!'),);
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,title: 'Set up your profile',removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text('Create a username',style: TextStyle(fontSize: 25),),
                  ),
                ),
                Padding(padding: EdgeInsets.all(16),
                  child: Container(
                    child: Form(
                      key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          validator: (value){
                            if(value.trim().length < 3 || value.isEmpty){
                              return 'username too short';
                            }else if(value.trim().length > 12){
                              return 'username too long';
                            }else{
                              return null;
                            }
                          },
                          onSaved: (value) => username = value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'username',
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: 'Must me at least 3 characters'
                          ),
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      child: Center(child: Text('Submit',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),)),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0)
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
