import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomBorderButton extends StatelessWidget {
  CustomBorderButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.focusNode,
    this.onLongPress,
    this.color,
    this.textColor,
  }) : super(
    key: key
  );

  FocusNode focusNode;
  String text;
  Function onPressed;
  Function onLongPress;
  Color color;
  Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
      width: double.maxFinite,
      child: FlatButton(
        padding: EdgeInsets.all(12.0),
        color: Colors.white,
        textColor: Theme.of(context).primaryColor,
        shape:  new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(4.0),
          side: BorderSide(
            color: Theme.of(context).primaryColor.withAlpha(150),
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(text,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
      ),
    );
  }
}