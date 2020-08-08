import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:antri_tino/main.dart';
import 'package:progress_dialog/progress_dialog.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _dbUser = FirebaseDatabase.instance.reference().child('users');

class AuthNamePage extends StatefulWidget {
  AuthNamePage({
    Key key,
    @required this.user,
  }) : assert(user != null),super(key: key);

  final FirebaseUser user;
  @override
  _AuthNamePageState createState() => _AuthNamePageState();
}

class _AuthNamePageState extends State<AuthNamePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController inputController = TextEditingController();

  bool isValid;
  ProgressDialog pr;

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
          showHeader(),
          showLeadingMessage(),
          showInput(),
        ],
      ),
    );
  }

  Widget showHeader() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Align(
          alignment: Alignment(-1.0, 0.0),
          child: Icon(
            Icons.account_box,
            size: 100.0,
            color: Theme.of(context).primaryColor,
          ),
        )
    );
  }

  Widget showLeadingMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'Hi, how can I address you?\n',
                style: TextStyle(fontSize: 24.0, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
            TextSpan(text: 'Please provide your name:',
                style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
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
        keyboardType: TextInputType.text,
        controller: inputController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0.0),
          hintText: "... ...",
          hintStyle: TextStyle(fontWeight: FontWeight.bold),
          counterStyle: TextStyle(fontSize: 15),
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
        maxLength: 30,
        maxLines: 1,
        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal),
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
            onPressed: confirmAndSaveName,
          ),
        ));
  }

  Future<void> confirmAndSaveName() async {
    if (widget.user != null) {
      final IdTokenResult token = (await widget.user.getIdToken(refresh: true));
      if (token != null) {
        String displayName = inputController.text.trim();

        pr.show().whenComplete(() {
          pr.update(
            message: 'Processing...',
          );
          _dbUser.child(widget.user.uid).set({
            'phone': widget.user.phoneNumber,
            'display_name': displayName,
            'token': token.token,
          }).then((done) {
            UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
            userUpdateInfo.displayName = displayName;
            widget.user.updateProfile(userUpdateInfo).whenComplete(() {
              pr.hide();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ), (Route<dynamic> route) => false
              );
            });
          }).catchError((err) {
            pr.hide();
            _errorModalAndSignout("Failed", "Setting name failed! [2]");
          });
        });
      } else {
        _errorModalAndSignout("Failed", "Sign in failed! [1]");
      }
    } else {
      _errorModalAndSignout("Failed", "Sign in failed! [0]");
    }
  }

  Future<void> validate() async {
    if (inputController.text.length >= 4) {
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
              },
            )
          ],
        );
      },
    );
  }

}