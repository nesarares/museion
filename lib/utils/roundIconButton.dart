import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final double iconSize;
  final Function onPressed;
  final IconData icon;

  RoundIconButton({Key key, this.iconSize = 24, this.onPressed, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: CircleBorder(),
      splashColor: Colors.white.withOpacity(0.2),
      onPressed: onPressed,
      padding: EdgeInsets.all(12),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}
