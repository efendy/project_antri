import 'package:flutter/material.dart';

class FocusUtil {
  static void fieldFocusChange(BuildContext context, FocusNode nextFocus) {
    FocusNode currentFocus = FocusScope.of(context).focusedChild;
    if (currentFocus != null) {
      currentFocus.unfocus();
    }
    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }
}