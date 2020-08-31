import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/components/btn.dart';
import 'package:flutterweather/views/home.dart';
import 'package:flutterweather/views/menu.dart';
import 'package:flutterweather/services/location.dart';

void main() => runApp(new MainApp());

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool loading = true;
  int selectedAccent = 0;
  bool isDrawerOpen = false;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

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
              onAccentSelect: onAccentSelect,
              isDrawerOpen: isDrawerOpen,
              accent: selectedAccent,
              onNavPress: toggleMenu,
            ),
            Positioned(
              child: Btn(
                onPress: toggleMenu,
                child: Icon(
                  Icons.close,
                  size: 32,
                ),
              ),
              top: 24,
              left: 24,
            ),
            Positioned(
              child: Btn(
                onPress: getLocation,
                child: Icon(
                  Icons.refresh,
                  size: 32,
                ),
              ),
              top: 24,
              right: 24,
            ),
            Home(
              isDrawerOpen: isDrawerOpen,
              onNavPress: toggleMenu,
              accent: selectedAccent,
              location: location,
              loading: loading,
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

  void onAccentSelect(int i) {
    setState(() {
      selectedAccent = i;
    });
  }

  void getLocation() async {
    setState(() {
      loading = true;
    });
    try {
      await location.getCurrentLocation();
      await location.getLocationData();
      // await location.getCityData("Kolkata");
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
