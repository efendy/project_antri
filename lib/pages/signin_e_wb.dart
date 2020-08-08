import 'package:antri_tino/widgets/custom_flat_button.dart';
import 'package:antri_tino/widgets/custom_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:antri_tino/main.dart';
import 'package:progress_dialog/progress_dialog.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _dbUser = FirebaseDatabase.instance.reference().child('users');

class AuthWelcomebackPage extends StatefulWidget {
  AuthWelcomebackPage({
    Key key,
    @required this.user,
  }) : assert(user != null),super(key: key);

  final FirebaseUser user;
  @override
  _AuthWelcomebackPageState createState() => _AuthWelcomebackPageState();
}

class _AuthWelcomebackPageState extends State<AuthWelcomebackPage> {
  final TextEditingController inputController = TextEditingController();

  ProgressDialog pr;

  @override
  void initState() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget showForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Welcome back, ' + widget.user.displayName + '!\n',
              style: TextStyle(fontSize: 24.0, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
          Expanded(
            child: showLeadingMessage(),
          ),
          Container(
            width: double.maxFinite,
            child: CustomFlatButton(
              text: 'Yes, that\'s my account',
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: confirmAndSaveName,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
            width: double.maxFinite,
            child: CustomFlatButton(
              text: 'No, that\'s not me',
              color: Colors.transparent,
              textColor: Theme.of(context).primaryColor,
              onPressed: () {
                _asyncLogoutDialog(context);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget showLeadingMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'We found an account registered to ',
                style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
            TextSpan(text: widget.user.phoneNumber + '\n',
                style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
            TextSpan(text: 'Is this you?',
                style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
          ],
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Future<void> confirmAndSaveName() async {
    if (widget.user != null) {
      final IdTokenResult token = (await widget.user.getIdToken(refresh: true));
      if (token != null) {

        pr.show();
        pr.update(
          message: 'Processing...',
        );
        _dbUser.child(widget.user.uid).update({
          'token': token.token,
        }).then((done) {
          pr.hide();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ), (Route<dynamic> route) => false
          );
        }).catchError((err) {
          pr.hide();
          _errorModalAndSignout("Failed", "Setting name failed! [2]");
        });
      } else {
        _errorModalAndSignout("Failed", "Sign in failed! [1]");
      }
    } else {
      _errorModalAndSignout("Failed", "Sign in failed! [0]");
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
                // @TODO remove displayName
                _auth.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _asyncLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign out'),
          content: const Text(
              'Signing out the account. Do you want to reset this account?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('CONFIRM'),
              textColor: Colors.grey,
              onPressed: () {
                _auth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ), (Route<dynamic> route) => false
                );
              },
            )
          ],
        );
      },
    );
  }
}