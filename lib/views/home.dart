import 'package:flutter/material.dart';
import 'package:flutterweather/components/hamburger.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double x = 0;
  double y = 0;
  double factor = 1;

  bool _drawerActive = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: EdgeInsets.all(24),
      transform: Matrix4.translationValues(x, y, 0)..scale(factor),
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: _drawerActive
            ? [BoxShadow(color: Colors.black38, blurRadius: 40.0)]
            : [],
        borderRadius: BorderRadius.circular(_drawerActive ? 48 : 0),
      ),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: [
                Hamburger(
                  onPressed: onMenuPress,
                )
              ],
            ),
          ),
          Text(
            "HEY",
            style: TextStyle(fontSize: 48),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void onMenuPress() {
    if (_drawerActive == false) {
      _drawerActive = true;
      setState(() {
        x = 230;
        y = 150;
        factor = 0.6;
      });
    } else {
      _drawerActive = false;
      setState(() {
        x = 0;
        y = 0;
        factor = 1;
      });
    }
  }
}
