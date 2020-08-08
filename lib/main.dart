import 'dart:io';

import 'package:antri_tino/pages/dashboard.dart';
import 'package:antri_tino/pages/signin_b_phone.dart';
import 'package:antri_tino/pages/signin_d_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _dbValidToken = FirebaseDatabase.instance.reference().child('_validToken');
//final DatabaseReference _dbUser = FirebaseDatabase.instance.reference().child('users');

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LiiiQ',
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.light,

          primaryColor: const Color(0xff344955),
          secondaryHeaderColor: const Color(0xff232f34),
//          backgroundColor: const Color(0xffffffff),
          scaffoldBackgroundColor: const Color(0xffffffff),
          // const Color(0xff4a6572)
          accentColor: const Color(0xfff9aa33),
//          backgroundColor: const Color(0xfff0f0f0),
          buttonTheme: ButtonThemeData(
            buttonColor: const Color(0xfff9aa33),
          ),
          // Define the default font family.
          fontFamily: 'Ubuntu',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            button: TextStyle(color: const Color(0xff232f34)),
//            headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//            title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal),
//            body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ),
        home: StreamBuilder<FirebaseUser>(
          stream: _auth.onAuthStateChanged,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                signInRoutingPage(context, snapshot);
              } else {
                return AuthPhonePage();
              }
            }
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 48.0,
                      child: Image.asset('assets/images/logo.png'),
                    )
                  ],
                ),
              ),
            );
          },
        )
    );
  }

  void signInRoutingPage(context, snapshot) {
    _dbValidToken.child("pass").once().then((respData) {
      if (snapshot.data.displayName == null || snapshot.data.displayName == "") {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AuthNamePage(user: snapshot.data),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DashboardPage(user: snapshot.data),
            ));
      }
    }).catchError((err) {
      stderr.writeln(err);
      _auth.signOut();
    });
  }
}
