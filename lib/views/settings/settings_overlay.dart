import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutterweather/components/overlay_card.dart';
import 'package:flutterweather/components/segmented_choice.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/services/unit_manager.dart';
import 'package:flutterweather/theme/app_theme.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

/// Full-screen settings panel on the shared [OverlayCard]: one row per setting.
/// The rows are Theme (a light/dark toggle), Language (opens the picker), Temperature (a toggle) and Rate on Google
/// Play. A new setting is a new row here. The panel stays open while a setting changes so the user sees it take effect.
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

  /// The menu used to tilt the sun and moon a little; they keep that tilt here.
  Widget _tilted(IconData icon) => Transform.rotate(angle: math.pi / 4.5, child: Icon(icon));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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

    return OverlayCard(
      title: l10n.settings,
      onClose: onClose,
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.theme, style: labelStyle()),
            trailing: SegmentedChoice<AppTheme>(
              accent: accentColor,
              textColor: theme.textColor,
              selected: theme.theme,
              onChanged: (AppTheme value) => theme.setTheme(value),
              options: [
                SegmentedOption(value: AppTheme.White, child: _tilted(Icons.wb_sunny), semanticLabel: l10n.lightTheme),
                SegmentedOption(
                    value: AppTheme.Dark, child: _tilted(Icons.brightness_3), semanticLabel: l10n.darkTheme),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.language, style: labelStyle()),
            trailing: Text(languageName, style: TextStyle(color: accentColor, fontSize: 16)),
            onTap: onLanguage,
          ),
          ListTile(
            title: Text(l10n.temperature, style: labelStyle()),
            trailing: SegmentedChoice<TemperatureUnit>(
              accent: accentColor,
              textColor: theme.textColor,
              selected: units.unit,
              onChanged: (TemperatureUnit unit) => _chooseUnit(units, unit),
              options: const [
                SegmentedOption(value: TemperatureUnit.celsius, child: Text('°C')),
                SegmentedOption(value: TemperatureUnit.fahrenheit, child: Text('°F')),
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
    );
  }
}
