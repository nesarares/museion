import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  final String header;

  const TextHeader({Key key, this.header}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 50, 30, 10),
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
