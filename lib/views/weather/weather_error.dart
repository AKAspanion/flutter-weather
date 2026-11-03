import 'package:flutter/material.dart';
import 'package:flutterweather/l10n/app_localizations.dart';

class ErrorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text(
          AppLocalizations.of(context)!.errorFetching.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red[400],
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
