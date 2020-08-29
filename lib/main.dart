import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/views/home.dart';
import 'package:flutterweather/views/menu.dart';

void main() => runApp(new MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: "Beautiful Weather",
      theme: ThemeData(fontFamily: "Montserrat"),
      home: Scaffold(
        body: Stack(
          children: [
            Menu(),
            Home(),
          ],
        ),
      ),
    );
  }
}
