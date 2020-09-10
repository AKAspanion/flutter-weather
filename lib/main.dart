import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/components/btn.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:flutterweather/views/home/dialog_overlay.dart';
import 'package:flutterweather/views/home/home.dart';
import 'package:flutterweather/views/menu/menu.dart';
import 'package:flutterweather/services/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MainApp());

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  bool loading = true;
  int selectedAccent = 0;
  bool isDialogOpen = false;
  bool isDrawerOpen = false;
  Location location = Location();

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    getLocation();
    getAccent();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      debugPrint("animation cancelled");
    }
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
                    onPress: onRefresh,
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
                    child: Transform.rotate(
                      angle: 3.1415926535897932 / 4.5,
                      child: Icon(
                        manager.theme == AppTheme.Dark
                            ? Icons.wb_sunny
                            : Icons.brightness_3,
                        size: 32,
                      ),
                    ),
                  ),
                  top: 24,
                  left: 98,
                ),
                Positioned(
                  child: Btn(
                    onPress: () => toggleDialog(true),
                    child: Icon(
                      Icons.location_on,
                      size: 32,
                    ),
                  ),
                  top: 24,
                  right: 98,
                ),
                Home(
                  controller: _controller.view,
                  isDrawerOpen: isDrawerOpen,
                  onNavPress: toggleMenu,
                  accent: selectedAccent,
                  location: location,
                  loading: loading,
                ),
                isDialogOpen
                    ? DialogOverlay(
                        accent: selectedAccent,
                        onCancel: () => toggleDialog(false),
                        onSubmit: (city) => onSubmit(city),
                      )
                    : Container(),
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

  void toggleDialog(bool value) {
    setState(() {
      isDialogOpen = value;
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

  Future<bool> setCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("city_preference", city);

    return true;
  }

  Future<String> getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String preferredCity = prefs.getString("city_preference") ?? "";

    return preferredCity;
  }

  void onRefresh() async {
    await setCity("");

    getLocation();
  }

  void onSubmit(String city) async {
    await setCity(city);

    getLocation();
  }

  void getLocation() async {
    String city = await getCity();

    if (city != "") {
      toggleDialog(false);
    }

    setState(() {
      loading = true;
    });
    try {
      await location.getCurrentLocation();
      if (city == "") {
        await location.getLocationData();
      } else {
        await location.getCityData(city);
      }

      final Weather weather = location.getWeather();
      await location.getForecast(weather.latitude, weather.longitude);

      _controller.reset();
      _playAnimation();
    } catch (e) {
      setState(() {
        location = Location();
      });
      debugPrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
