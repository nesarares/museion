import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final double iconSize;
  final Function onPressed;
  final IconData icon;
  final Color color;

  RoundIconButton(
      {Key key,
      this.iconSize = 24,
      this.onPressed,
      this.icon,
      this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: CircleBorder(),
      splashColor: color.withOpacity(0.2),
      onPressed: onPressed,
      padding: EdgeInsets.all(12),
      highlightColor: color.withOpacity(0.1),
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    );
  }
}
