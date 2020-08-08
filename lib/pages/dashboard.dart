import 'package:antri_tino/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key, @required this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("LiiiQ"),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.person_outline),
          onPressed: () {
            _asyncLogoutDialog(context);
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) =>
//                      ProfilePage(user: widget.user),
//                ));
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 44,
          ),
        ],
      ),
      bottomSheet: Container(
        height: 44,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _asyncLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logging out?'),
          content: const Text(
              'Confirming this to logout your account.'),
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
