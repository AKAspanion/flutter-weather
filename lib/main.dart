import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterweather/components/ad_banner.dart';
import 'package:flutterweather/components/system_insets.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/ads.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/play_store.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather_cache.dart';
import 'package:flutterweather/services/weather_service.dart';
import 'package:flutterweather/services/weather_widget.dart';
import 'package:flutterweather/views/forecast/forecast.dart';
import 'package:flutterweather/views/home/dialog_overlay.dart';
import 'package:flutterweather/views/home/home.dart';
import 'package:flutterweather/views/home/language_overlay.dart';
import 'package:flutterweather/views/menu/menu.dart';
import 'package:flutterweather/views/menu/menu_buttons.dart';
import 'package:flutterweather/views/settings/settings_overlay.dart';
import 'package:flutterweather/services/location.dart';
import 'package:geolocator/geolocator.dart';
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
  bool isSettingsOpen = false;
  bool isLanguageOpen = false;
  bool isDrawerOpen = false;
  bool isForecastOpen = false;
  // Keeps the forecast's animated icons alive only while the panel is on screen.
  bool isForecastMounted = false;
  Location location = Location();
  final WeatherService _weatherService = WeatherService.withDefaultProviders();
  final GlobalKey<ScaffoldMessengerState> _messenger = GlobalKey();
  // Height of the banner ad once one has loaded.
  double adHeight = 0;

  late Animation<double> yTranslate;
  late AnimationController _controller;
  late AnimationController _controllerMenu;
  late AnimationController _controllerForecast;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _loadCachedReport();
    getLocation();
    // The ads SDK is heavy; start it after the first frame so launch isn't slowed.
    WidgetsBinding.instance.addPostFrameCallback((_) => Ads.initialize());
    WeatherWidget.scheduleRefresh();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LocaleManager()..load()),
        ChangeNotifierProvider(create: (_) => UnitManager()..load()),
      ],
      child: Consumer2<ThemeManager, LocaleManager>(builder: (_, manager, localeManager, __) {
        return MaterialApp(
          title: "Beautiful Weather",
          scaffoldMessengerKey: _messenger,
          theme: manager.themeData,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeManager.locale,
          home: Scaffold(
            body: Stack(
              children: [
                Menu(
                  isDrawerOpen: isDrawerOpen,
                  onAccentSelect: setAccent,
                  accent: selectedAccent,
                  onNavPress: toggleMenu,
                  bottomInset: SystemInsets.contentBottom(context, adHeight),
                ),
                Positioned(
                  top: SystemInsets.buttonRowTop(context),
                  left: 0,
                  right: 0,
                  child: FutureBuilder<bool>(
                    future: WeatherWidget.canPin(),
                    builder: (_, snapshot) => _translateBuilder(
                      MenuButtons(
                        onRefresh: onRefresh,
                        onPinWidget: snapshot.data == true ? WeatherWidget.pin : null,
                        onSettings: () => toggleSettings(true),
                        onLocation: () => toggleDialog(true),
                        onClose: toggleMenu,
                      ),
                      amount: 0.6,
                    ),
                  ),
                ),
                Home(
                  controller: _controller.view,
                  isDrawerOpen: isDrawerOpen,
                  onMorePress: toggleForecast,
                  onNavPress: toggleMenu,
                  accent: selectedAccent,
                  location: location,
                  // Cached weather stays on screen while a refresh runs.
                  loading: loading && location.getWeather() == null,
                  bottomInset: SystemInsets.contentBottom(context, adHeight),
                ),
                isDialogOpen
                    ? DialogOverlay(
                        accent: selectedAccent,
                        onCancel: () => toggleDialog(false),
                        onSubmit: (city) => onSubmit(city),
                      )
                    : Container(),
                isSettingsOpen
                    ? SettingsOverlay(
                        accent: selectedAccent,
                        onClose: () => toggleSettings(false),
                        // The picker opens above the panel, which stays open under it.
                        onLanguage: () => toggleLanguage(true),
                        onRate: onRate,
                        onUnitChanged: onUnitChanged,
                      )
                    : Container(),
                isLanguageOpen
                    ? LanguageOverlay(
                        accent: selectedAccent,
                        onClose: () => toggleLanguage(false),
                      )
                    : Container(),
                Forecast(
                  controller: _controllerForecast,
                  isWindowOpen: isForecastOpen,
                  onClosePress: toggleForecast,
                  showContent: isForecastMounted,
                  bottomInset: SystemInsets.contentBottom(context, adHeight),
                  accent: selectedAccent,
                  location: location,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: SystemInsets.adBottom(context),
                  child: Center(
                    child: AdBanner(
                      onHeightChanged: (height) => setState(() => adHeight = height),
                    ),
                  ),
                ),
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
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, yTranslate.value * amount),
          child: child,
        );
      },
    );
  }

  void toggleForecast() {
    if (isForecastOpen) {
      _controller.reset();
      _playAnimation();
      // Unmount the content once the panel has finished sliding away.
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !isForecastOpen) setState(() => isForecastMounted = false);
      });
    } else {
      isForecastMounted = true;
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

  void toggleSettings(bool value) {
    setState(() {
      isSettingsOpen = value;
    });
  }

  void toggleLanguage(bool value) {
    setState(() {
      isLanguageOpen = value;
    });
  }

  void setAccent(int i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("accent_preference", i);
    WeatherWidget.setAccent(i);

    setState(() {
      selectedAccent = i;
    });
  }

  void getAccent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int preferredAccent = prefs.getInt("accent_preference") ?? 0;
    WeatherWidget.setAccent(preferredAccent);

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
      final WeatherQuery query;
      if (city == "") {
        final Position? position = await Location.currentPosition();
        if (position == null) {
          throw ("No lat or lon data found");
        }
        query = WeatherQuery.coords(position.latitude, position.longitude);
      } else {
        query = WeatherQuery.city(city);
      }

      final WeatherReport report = await query.fetch(_weatherService);
      await WeatherCache.save(report, query);
      _showReport(report);
      WeatherWidget.update(report);
    } catch (e) {
      debugPrint(e.toString());
      if (location.getWeather() != null) {
        _messenger.currentState?.showSnackBar(
          // This State sits above the MaterialApp, so the text is looked up where the snackbar is built.
          SnackBar(content: Builder(builder: (context) => Text(AppLocalizations.of(context)!.updateFailed))),
        );
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onRate() async {
    final bool opened = await PlayStore.openListing();
    if (!opened && mounted) {
      _messenger.currentState?.showSnackBar(
        // This State sits above the MaterialApp, so the text is looked up where the snackbar is built.
        SnackBar(content: Builder(builder: (context) => Text(AppLocalizations.of(context)!.couldNotOpenPlayStore))),
      );
    }
  }

  /// Pushes the last cached report to the home-screen widget so it switches unit now, not at its next refresh.
  void onUnitChanged() async {
    final WeatherReport? cached = await WeatherCache.loadReport();
    if (cached != null) WeatherWidget.update(cached);
  }

  void _loadCachedReport() async {
    final WeatherReport? cached = await WeatherCache.loadReport();
    if (cached != null && mounted && location.getWeather() == null) {
      _showReport(cached);
    }
  }

  void _showReport(WeatherReport report) {
    setState(() {
      location = Location(report);
    });

    _controller.reset();
    _playAnimation();
  }
}
