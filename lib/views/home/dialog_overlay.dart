import 'package:flutter/material.dart';
import 'package:flutterweather/components/overlay_card.dart';
import 'package:flutterweather/l10n/app_localizations.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/contrast.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

/// The city search overlay: a CITY card with one field. The ✓ at the end of the field and the keyboard's Done key both
/// submit the typed text to [onSubmit]; the header close calls [onCancel].
class DialogOverlay extends StatefulWidget {
  final int accent;
  final void Function(String city) onSubmit;
  final void Function() onCancel;

  const DialogOverlay({super.key, required this.accent, required this.onSubmit, required this.onCancel});

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  String city = "";

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeManager theme = Provider.of<ThemeManager>(context);
    final Color textColor = theme.textColor;
    final Color accent =
        readableOn(GradientValues().gradients[widget.accent].gradient[0], theme.bgColor, minRatio: shapeContrast);

    return OverlayCard(
      title: l10n.city,
      onClose: _cancel,
      child: Padding(
        // The card pads its content by 12; 16 here lines the field up with the title above it.
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: _updateCity,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: l10n.cityName,
            labelStyle: TextStyle(color: textColor),
            prefixIcon: Icon(Icons.location_city, color: accent),
            suffixIcon: IconButton(icon: Icon(Icons.done, color: accent), onPressed: _submit),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accent)),
            border: OutlineInputBorder(borderSide: BorderSide(color: accent)),
          ),
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }

  void _updateCity(String text) {
    setState(() {
      city = text;
    });
  }

  void _cancel() {
    widget.onCancel();
    _updateCity("");
  }

  void _submit() {
    widget.onSubmit(city);
    _updateCity("");
  }
}
