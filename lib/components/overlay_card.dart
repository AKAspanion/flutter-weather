import 'package:flutter/material.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:provider/provider.dart';

/// The card every full-screen overlay (city dialog, language picker, settings panel) sits in, so they look and close
/// the same way: a dimmed backdrop, a rounded card with the upper-cased [title] at the start and a close button at the
/// end, and [child] below, scrolling when it doesn't fit. Reads [ThemeManager] from Provider and returns a
/// [Positioned.fill], so it goes straight into a Stack.
class OverlayCard extends StatelessWidget {
  final String title;
  final void Function() onClose;
  final Widget child;

  const OverlayCard({super.key, required this.title, required this.onClose, required this.child});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeManager theme = Provider.of<ThemeManager>(context);

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: size.width - 64,
            constraints: BoxConstraints(maxHeight: size.height - 100),
            // The close button sits at the top end, so the end padding is the same 12 as the start.
            padding: const EdgeInsetsDirectional.only(top: 24, bottom: 12, start: 12, end: 12),
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
                  Row(
                    children: [
                      Expanded(
                        // ListTile insets its text by 16 inside the card padding, so the same 16 lines the title
                        // up with the rows below it.
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 16),
                          child: Text(
                            title.toUpperCase(),
                            style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.textColor),
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
