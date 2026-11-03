import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an address outside the app and says whether something handled it.
typedef UrlOpener = Future<bool> Function(Uri uri);

Future<bool> _launchExternally(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

/// The app's own Google Play page.
class PlayStore {
  /// The application ID in `android/app/build.gradle.kts`.
  static const String packageId = 'in.spanion.weather';

  /// Opens the Play app on the listing, or the web page when the Play app can't be reached, and returns whether one
  /// opened. Launcher errors are logged, not thrown. [open] is for tests; it defaults to the system launcher.
  static Future<bool> openListing({UrlOpener? open}) async {
    final UrlOpener opener = open ?? _launchExternally;
    final List<Uri> addresses = [
      Uri.parse('market://details?id=$packageId'),
      Uri.parse('https://play.google.com/store/apps/details?id=$packageId'),
    ];
    for (final Uri address in addresses) {
      try {
        if (await opener(address)) return true;
      } catch (e) {
        debugPrint('Could not open $address: $e');
      }
    }
    return false;
  }
}
