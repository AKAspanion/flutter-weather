import 'package:flutter/material.dart';
import 'package:flutterweather/components/overlay_card.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

/// Full-screen picker for the app's language on the shared [OverlayCard]: "System default" first, then each
/// supported language in its own script. Choosing one applies it at once and closes the overlay.
class LanguageOverlay extends StatelessWidget {
  final int accent;
  final void Function() onClose;

  const LanguageOverlay({required this.accent, required this.onClose});

  void _choose(BuildContext context, Locale? locale) {
    // setLocale never throws, and the app switches language as soon as it notifies.
    context.read<LocaleManager>().setLocale(locale);
    onClose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeManager theme = Provider.of<ThemeManager>(context);
    final Color accentColor = GradientValues().gradients[accent].gradient[0];
    final Locale? current = context.watch<LocaleManager>().locale;

    Widget row(String label, Locale? locale) {
      final bool selected = current?.languageCode == locale?.languageCode;
      return ListTile(
        dense: true,
        title: Text(label, style: TextStyle(color: theme.textColor, fontSize: 18)),
        trailing: selected ? Icon(Icons.check, color: accentColor) : null,
        onTap: () => _choose(context, locale),
      );
    }

    return OverlayCard(
      title: l10n.language,
      onClose: onClose,
      child: Column(
        children: [
          row(l10n.systemDefault, null),
          for (final Language language in supportedLanguages) row(language.nativeName, Locale(language.code)),
        ],
      ),
    );
  }
}
