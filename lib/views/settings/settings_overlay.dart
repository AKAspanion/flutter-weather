import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

/// Full-screen settings panel, laid out like the language picker: a title, one row per setting, and a close button.
/// The rows are Language (opens the picker), Temperature (a toggle that applies at once) and Rate on Google Play.
/// A new setting is a new row here. The panel stays open while a setting changes so the user sees it take effect.
class SettingsOverlay extends StatelessWidget {
  final int accent;
  final void Function() onClose;
  final void Function() onLanguage;
  final void Function() onRate;

  /// Called after UnitManager.setUnit has finished saving, so the widget reads the new unit.
  final void Function() onUnitChanged;

  const SettingsOverlay({
    required this.accent,
    required this.onClose,
    required this.onLanguage,
    required this.onRate,
    required this.onUnitChanged,
  });

  Future<void> _chooseUnit(UnitManager units, TemperatureUnit unit) async {
    if (units.unit == unit) return;
    await units.setUnit(unit);
    onUnitChanged();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;
    final ThemeManager theme = Provider.of<ThemeManager>(context);
    final Color accentColor = GradientValues().gradients[accent].gradient[0];
    final Locale? locale = context.watch<LocaleManager>().locale;
    final UnitManager units = context.watch<UnitManager>();

    final String languageName = locale == null
        ? l10n.systemDefault
        : supportedLanguages
            .firstWhere((l) => l.code == locale.languageCode, orElse: () => const Language('', ''))
            .nativeName;

    TextStyle labelStyle() => TextStyle(color: theme.textColor, fontSize: 18);

    Widget unitSegment(TemperatureUnit unit, String label) {
      final bool selected = units.unit == unit;
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _chooseUnit(units, unit),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : theme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: size.width - 64,
            constraints: BoxConstraints(maxHeight: size.height - 100),
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            decoration: BoxDecoration(
              color: theme.bgColor,
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 40.0)],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.settings.toUpperCase(),
                    style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(l10n.language, style: labelStyle()),
                            trailing: Text(languageName, style: TextStyle(color: accentColor, fontSize: 16)),
                            onTap: onLanguage,
                          ),
                          ListTile(
                            title: Text(l10n.temperature, style: labelStyle()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                unitSegment(TemperatureUnit.celsius, '°C'),
                                const SizedBox(width: 4),
                                unitSegment(TemperatureUnit.fahrenheit, '°F'),
                              ],
                            ),
                          ),
                          ListTile(
                            title: Text(l10n.rateOnGooglePlay, style: labelStyle()),
                            trailing: Icon(Icons.open_in_new, color: theme.textColor),
                            onTap: onRate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: IconButton(
                        icon: Icon(Icons.close, color: theme.textColor),
                        onPressed: onClose,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
