import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/components/btn.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:flutterweather/views/forecast/forecast.dart';
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
  bool isForecastOpen = false;
  Location location = Location();

  Animation<double> yTranslate;
  AnimationController _controller;
  AnimationController _controllerMenu;
  AnimationController _controllerForecast;

  @override
  void initState() {
    super.initState();
    getLocation();
    getAccent();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controllerMenu = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _controllerForecast = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    yTranslate = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controllerMenu,
        curve: Interval(
          0.000,
          1.000,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      debugPrint("home animation cancelled");
    }
  }

  Future<void> _playReverseAnimation() async {
    try {
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      debugPrint("home reverse animation cancelled");
    }
  }

  Future<void> _playMenuAnimation() async {
    try {
      await _controllerMenu.forward().orCancel;
    } on TickerCanceled {
      debugPrint("menu animation cancelled");
    }
  }

  Future<void> _playReverseMenuAnimation() async {
    try {
      await _controllerMenu.reverse().orCancel;
    } on TickerCanceled {
      debugPrint("menu reverse animation cancelled");
    }
  }

  Future<void> _playForecastAnimation() async {
    try {
      await _controllerForecast.forward().orCancel;
    } on TickerCanceled {
      debugPrint("forecast animation cancelled");
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
                  child: _translateBuilder(
                    Btn(
                      onPress: onRefresh,
                      child: Icon(
                        Icons.refresh,
                        size: 32,
                      ),
                    ),
                    amount: 0.6,
                  ),
                  top: 24,
                  left: 24,
                ),
                Positioned(
                  child: _translateBuilder(
                    Btn(
                      onPress: toggleMenu,
                      child: Icon(
                        Icons.close,
                        size: 32,
                      ),
                    ),
                    amount: 0.6,
                  ),
                  top: 24,
                  right: 24,
                ),
                Positioned(
                  child: _translateBuilder(
                    Btn(
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
                  ),
                  top: 24,
                  left: 98,
                ),
                Positioned(
                  child: _translateBuilder(
                    Btn(
                      onPress: () => toggleDialog(true),
                      child: Icon(
                        Icons.location_on,
                        size: 32,
                      ),
                    ),
                  ),
                  top: 24,
                  right: 98,
                ),
                Home(
                  controller: _controller.view,
                  isDrawerOpen: isDrawerOpen,
                  onMorePress: toggleForecast,
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
                Forecast(
                  controller: _controllerForecast,
                  isWindowOpen: isForecastOpen,
                  onClosePress: toggleForecast,
                  accent: selectedAccent,
                  location: location,
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  _translateBuilder(Widget ch, {amount = 1}) {
    return AnimatedBuilder(
      animation: _controllerMenu,
      child: ch,
      builder: (BuildContext context, Widget child) {
        return Transform.translate(
          offset: Offset(0, yTranslate.value * amount),
          child: child,
        );
      },
    );
  }

  void toggleTheme(manager) {
    if (manager.theme == AppTheme.White) {
      manager.setTheme(AppTheme.Dark);
    } else {
      manager.setTheme(AppTheme.White);
    }
  }

  void toggleForecast() {
    if (isForecastOpen) {
      _controller.reset();
      _playAnimation();
    } else {
      _playReverseAnimation();

      _controllerForecast.reset();
      _playForecastAnimation();
    }
    setState(() {
      isForecastOpen = !isForecastOpen;
    });
  }

  void toggleMenu() {
    if (!isDrawerOpen) {
      _controllerMenu.reset();
      _playMenuAnimation();
    } else {
      _playReverseMenuAnimation();
    }
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
      Location newLocation = Location();
      await newLocation.getCurrentLocation();
      if (city == "") {
        await newLocation.getLocationData();
      } else {
        await newLocation.getCityData(city);
      }

      final Weather weather = newLocation.getWeather();
      await newLocation.getForecast(weather.latitude, weather.longitude);

      setState(() {
        location = newLocation;
      });

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
