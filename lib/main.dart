import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/components/btn.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:flutterweather/views/home.dart';
import 'package:flutterweather/views/menu.dart';
import 'package:flutterweather/services/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    getAccent();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(builder: (_, manager, __) {
        return MaterialApp(
          title: "Beautiful Weather",
          theme: manager.themeData,
          home: Scaffold(
            body: Stack(
              children: [
                Menu(
                  isDrawerOpen: isDrawerOpen,
                  onAccentSelect: setAccent,
                  accent: selectedAccent,
                  onNavPress: toggleMenu,
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
                  left: 24,
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
                  right: 24,
                ),
                Positioned(
                  child: Btn(
                    onPress: () => toggleTheme(manager),
                    child: Icon(
                      manager.theme == AppTheme.White
                          ? Icons.wb_sunny
                          : Icons.brightness_3,
                      size: 32,
                    ),
                  ),
                  top: 24,
                  left: 98,
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
      }),
    );
  }

  void toggleTheme(manager) {
    if (manager.theme == AppTheme.White) {
      manager.setTheme(AppTheme.Dark);
    } else {
      manager.setTheme(AppTheme.White);
    }
  }

  void toggleMenu() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  void setAccent(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("accent_preference", i);

    setState(() {
      selectedAccent = i;
    });
  }

  void getAccent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int preferredAccent = prefs.getInt("accent_preference") ?? 0;

    setState(() {
      selectedAccent = preferredAccent;
    });
  }

  void getLocation() async {
    setState(() {
      loading = true;
    });
    try {
      await location.getCurrentLocation();
      await location.getLocationData();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
