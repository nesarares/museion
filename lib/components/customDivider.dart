import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  CustomDivider() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
      width: 64,
      child: Divider(color: Colors.white),
    );
  }
}
