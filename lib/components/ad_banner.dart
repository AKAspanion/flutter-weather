import 'package:flutter/material.dart';
import 'package:flutterweather/services/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Full-width anchored adaptive banner. Takes no space until an ad loads,
/// then reports its height so screens can make room for it.
class AdBanner extends StatefulWidget {
  final void Function(double height) onHeightChanged;

  AdBanner({required this.onHeightChanged});

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;
  int? _width;

  @override
  void initState() {
    super.initState();
    Ads.ready.addListener(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int width = MediaQuery.of(context).size.width.truncate();
    if (width != _width) {
      _width = width;
      _load();
    }
  }

  Future<void> _load() async {
    if (!Ads.ready.value || _width == null) return;

    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(_width!);
    if (size == null || !mounted) return;

    _banner?.dispose();
    _loaded = false;
    _banner = BannerAd(
      adUnitId: Ads.bannerUnitId,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
          widget.onHeightChanged(size.height.toDouble());
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: ${error.message}');
          ad.dispose();
          if (_banner == ad) _banner = null;
          if (mounted) setState(() => _loaded = false);
          widget.onHeightChanged(0);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    Ads.ready.removeListener(_load);
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? banner = _banner;
    if (!_loaded || banner == null) return SizedBox.shrink();

    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
