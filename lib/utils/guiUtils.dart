import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GuiUtils {
  static void showErrorNotification(BuildContext context, {String message}) {
    showNotification(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: FeatherIcons.alertCircle,
    );
  }

  static void showWarningNotification(BuildContext context, {String message}) {
    showNotification(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: FeatherIcons.alertTriangle,
    );
  }

  static void showNotification(BuildContext context,
      {String message, Color backgroundColor, IconData icon}) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      messageText: Text(
        message,
        style: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15),
      ),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      backgroundColor: backgroundColor,
      duration: Duration(milliseconds: 3500),
      animationDuration: Duration(milliseconds: 400),
      aroundPadding: EdgeInsets.all(8),
      borderRadius: 8,
      forwardAnimationCurve: Curves.ease,
      boxShadow: BoxShadow(
        color: Colors.black38,
        blurRadius: 5,
        offset: Offset.fromDirection(math.pi / 2, 2),
      ),
    ).show(context);
  }

  static int getValueFromString(String str) {
    return str.codeUnits.reduce((c1, c2) => c1 + c2);
  }
}
