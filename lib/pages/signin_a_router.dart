import 'package:antri_tino/utils/focus_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:antri_tino/pages/signin_c_otp.dart';

class AuthRouterPage extends StatefulWidget {
  AuthRouterPage({Key key}) : super(key: key);

  String inputPrefix = "+62";

  @override
  AuthRouterPageState createState() => AuthRouterPageState();
}

class AuthRouterPageState extends State<AuthRouterPage> {
  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
  }
}

