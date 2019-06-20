import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  final String header;
  final EdgeInsetsGeometry padding;

  const TextHeader(
      {Key key,
      this.header,
      this.padding = const EdgeInsets.fromLTRB(30, 50, 30, 10)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              header,
              softWrap: true,
              style: TextStyle(
                  fontFamily: 'Rufina',
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
          )
        ],
      ),
    );
  }
}
