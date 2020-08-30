import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final bool isDrawerOpen;
  final void Function() onNavPress;

  const Menu({Key key, @required this.isDrawerOpen, @required this.onNavPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      color: Colors.blueGrey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isDrawerOpen.toString()),
        ],
      ),
    );
  }
}
