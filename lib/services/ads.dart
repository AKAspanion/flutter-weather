import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob setup, gated on the user's consent (Google UMP / GDPR).
///
/// The IDs default to Google's test ads. Real ones come in at build time:
/// ADMOB_BANNER_ID here, ADMOB_APP_ID in android/app/build.gradle.kts.
class Ads {
  static const String _bannerUnitId = String.fromEnvironment('ADMOB_BANNER_ID');
  // Blank falls back to Google's test banner.
  static const String bannerUnitId =
      _bannerUnitId == '' ? 'ca-app-pub-3940256099942544/9214589741' : _bannerUnitId;

  /// True once the SDK is initialised and the user's consent allows ads.
  static final ValueNotifier<bool> ready = ValueNotifier(false);

  /// Whether the app must offer a way to revisit the consent choice.
  static final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);

  static bool _starting = false;

  // Only Android has an AdMob app ID configured; the iOS SDK crashes without one.
  static bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static void initialize() {
    if (!_supported) return;

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) debugPrint('Consent form: ${error.message}');
        _startIfAllowed();
      }),
      (FormError error) {
        debugPrint('Consent info update failed: ${error.message}');
        _startIfAllowed();
      },
    );
    // Consent given in an earlier session lets ads start right away.
    _startIfAllowed();
  }

  static void showPrivacyOptions() {
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) debugPrint('Privacy options form: ${error.message}');
    });
  }

  static Future<void> _startIfAllowed() async {
    privacyOptionsRequired.value = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;

    if (ready.value || _starting || !await ConsentInformation.instance.canRequestAds()) return;
    _starting = true;
    await MobileAds.instance.initialize();
    ready.value = true;
  }
}
