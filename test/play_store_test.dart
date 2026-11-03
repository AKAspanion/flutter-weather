import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/services/play_store.dart';

const String _market = 'market://details?id=in.spanion.weather';
const String _web = 'https://play.google.com/store/apps/details?id=in.spanion.weather';

/// Records each address tried and answers from [answers]: a bool, or a thrown error.
class _FakeLauncher {
  final Map<String, Object> answers;
  final List<String> tried = [];

  _FakeLauncher(this.answers);

  Future<bool> call(Uri uri) async {
    tried.add(uri.toString());
    final Object answer = answers[uri.toString()] ?? false;
    if (answer is bool) return answer;
    throw answer;
  }
}

void main() {
  test('names the app by its Play ID', () {
    expect(PlayStore.packageId, 'in.spanion.weather');
  });

  test('opens the Play app and goes no further when it works', () async {
    final launcher = _FakeLauncher({_market: true});

    expect(await PlayStore.openListing(open: launcher.call), isTrue);
    expect(launcher.tried, [_market]);
  });

  test('falls back to the web page when the Play app does not open', () async {
    final launcher = _FakeLauncher({_market: false, _web: true});

    expect(await PlayStore.openListing(open: launcher.call), isTrue);
    expect(launcher.tried, [_market, _web]);
  });

  test('returns false when neither address opens', () async {
    final launcher = _FakeLauncher({_market: false, _web: false});

    expect(await PlayStore.openListing(open: launcher.call), isFalse);
    expect(launcher.tried, [_market, _web]);
  });

  test('does not throw when the launcher throws', () async {
    final launcher = _FakeLauncher({_market: Exception('no handler'), _web: false});

    expect(await PlayStore.openListing(open: launcher.call), isFalse);
    expect(launcher.tried, [_market, _web]);
  });
}
