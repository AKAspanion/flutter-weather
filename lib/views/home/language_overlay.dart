import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/locale_manager.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

/// Full-screen picker for the app's language, laid out like the city dialog: "System default" first, then each
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
    final Size size = MediaQuery.of(context).size;
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

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: size.width - 100,
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
                    l10n.language.toUpperCase(),
                    style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          row(l10n.systemDefault, null),
                          for (final Language language in supportedLanguages)
                            row(language.nativeName, Locale(language.code)),
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
