import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomFlatButton extends StatelessWidget {
  CustomFlatButton({
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
  Color textColor = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    if (color == null) { color = Theme.of(context).accentColor; }
//    if (textColor == null) { color = Theme.of(context).color; }
    return FlatButton(
      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
      color: color,
      textColor: textColor,
      shape:  new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
      child: Text(text, style: TextStyle(
        fontSize: 20.0,
      )),
      onPressed: onPressed,
      onLongPress: onLongPress,
    );
  }
}