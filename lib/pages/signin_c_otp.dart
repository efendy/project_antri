import 'dart:io';

import 'package:antri_tino/pages/signin_d_name.dart';
import 'package:antri_tino/pages/signin_e_wb.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _dbUser = FirebaseDatabase.instance.reference().child('users');

class AuthOTPPage extends StatefulWidget {
  AuthOTPPage({
    Key key,
    @required this.mobileNumber,
  }) : assert(mobileNumber != null),super(key: key);

  final String mobileNumber;
  @override
  _AuthOTPPageState createState() => _AuthOTPPageState();
}

class _AuthOTPPageState extends State<AuthOTPPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController inputController = TextEditingController();

  String verificationId;
  ProgressDialog pr;

  bool isValid;

  @override
  void initState() {
    isValid = false;

    pr = new ProgressDialog(context);
    pr.style(
        borderRadius: 4.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600)
    );

    super.initState();
    verifyPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          Future.value(
              false); //return a `Future` with false value so this route cant be popped or closed.
        },
        child: Stack(
          children: <Widget>[
            showForm(),
          ],
        ),
      ),
      floatingActionButton: showConfirmButton(),
    );
  }

  Widget showForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          showBackButton(),
          showLeadingMessage(),
          showInput(),
        ],
      ),
    );
  }

  Widget showBackButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Align(
          alignment: Alignment(-1.0, 0.0),
          child: SizedBox(
            height: 40.0,
            width: 40.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () { Navigator.pop(context); },
            ),
          ),
        ));
  }

  Widget showLeadingMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'Enter the 6-digit code sent to:\n', style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
            TextSpan(text: widget.mobileNumber, style: TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
          ],
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget showInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: inputController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0.0),
          hintText: "000000",
          counterText: "",
          border: OutlineInputBorder(
            gapPadding: 0.0,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              style: BorderStyle.none,
              width: 0.0,
            ),
          ),
        ),
        autofocus: true,
        autovalidate: false,
        autocorrect: false,
        maxLengthEnforced: true,
        maxLength: 6,
        maxLines: 1,
        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        onChanged: (text) {
          validate();
        },
      ),
    );
  }

  Widget showConfirmButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: SizedBox(
          height: 30.0,
          child: FlatButton(
            color: Colors.transparent,
            textColor: (isValid ? Theme.of(context).accentColor : Colors.grey),
            child: Text('Confirm', style: TextStyle(
              fontSize: 20.0,
            )),
            onPressed: () { signInWithPhoneNumber(); },
          ),
        ));
  }

  Future<void> verifyPhoneNumber() async {

    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      print("PhoneVerificationFailed verificationId = ${phoneAuthCredential.toString()}");
      _auth.signInWithCredential(phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException) {
      _errorModalAndSignout("Failed", "Authentication failed! Code: ${authException.code}. Message: ${authException.message}");
    };

    final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) {
      print("PhoneCodeSent verificationId = ${verificationId}");
      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      print("PhoneCodeAutoRetrievalTimeout verificationId = ${verificationId}");
      this.verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: widget.mobileNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<void> signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: this.verificationId,
      smsCode: this.inputController.text.toString(),
    );
    FirebaseUser user;
    try {
      user = (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        pr.show().whenComplete(() {
          pr.update(
            message: 'Processing...',
          );
          sleep(Duration(seconds:2));
          validatingDisplayName(user);
        });
      } else {
        _errorModalAndSignout("Failed", "Sign in failed! [0]");
      }
    } catch (err) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Wrong code! Please try again.")
      ));
      inputController.text = "";
    }
  }

  void validatingDisplayName(FirebaseUser user) async {
    if (user.displayName == null || user.displayName == "") {
      pr.hide().whenComplete(() {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AuthNamePage(
                    user: user,
                  ),
            ));
      });
    } else {
      final IdTokenResult token = (await user.getIdToken(refresh: true));
      if (token != null) {
        _dbUser.child(user.uid).update({
          'token': token.token,
        }).whenComplete(() {
          pr.hide().whenComplete(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AuthWelcomebackPage(
                        user: user,
                      ),
                ));
          });
        });
      } else {
        _errorModalAndSignout("Failed", "Sign in failed! [1]");
      }
    }
  }

  Future<void> validate() async {
    if (inputController.text.length >= 6) {
      setState(() {
        isValid = true;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  void _errorModalAndSignout(String title, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
//                Navigator.pushAndRemoveUntil(
//                    context,
//                    MaterialPageRoute(
//                      builder: (context) => MyApp(),
//                    ), (Route<dynamic> route) => false
//                );
              },
            )
          ],
        );
      },
    );
  }

}