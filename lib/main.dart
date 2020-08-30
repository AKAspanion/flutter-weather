import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/views/home.dart';
import 'package:flutterweather/views/menu.dart';

void main() => runApp(new MainApp());

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: "Beautiful Weather",
      theme: ThemeData(fontFamily: "Montserrat"),
      home: Scaffold(
        body: Stack(
          children: [
            Menu(
              isDrawerOpen: isDrawerOpen,
              onNavPress: toggleMenu,
            ),
            Home(
              isDrawerOpen: isDrawerOpen,
              onNavPress: toggleMenu,
            ),
          ],
        ),
      ),
    );
  }

  void toggleMenu() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }
}
