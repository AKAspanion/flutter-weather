import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweather/services/providers/weather_provider.dart';
import 'package:flutterweather/services/weather.dart';
import 'package:flutterweather/services/weather_service.dart';

class FakeProvider extends WeatherProvider {
  @override
  final String name;
  @override
  final bool supportsCitySearch;
  bool failing;
  final String placeName;
  int calls = 0;

  FakeProvider(this.name, {this.failing = false, this.supportsCitySearch = true, this.placeName = 'Paris'});

  @override
  String get attribution => name;

  WeatherReport _report() {
    calls++;
    if (failing) throw ProviderException('$name is down');
    return WeatherReport(
      current: Weather(name: placeName, temperature: 290, condition: 800),
      hourly: [],
      daily: [],
      source: name,
      attribution: attribution,
    );
  }

  @override
  Future<WeatherReport> fetchByCoords(double lat, double lon, {required int timezone}) async => _report();

  @override
  Future<WeatherReport> fetchByCity(String city, {required int timezone}) async => _report();
}

class FakeGeocoderProvider extends FakeProvider implements Geocoder {
  FakeGeocoderProvider(String name, {bool failing = false}) : super(name, failing: failing);

  @override
  Future<Place?> search(String city) async => Place(name: 'Geocoded $city', lat: 48.85, lon: 2.35);

  @override
  Future<Place?> reverse(double lat, double lon) async => Place(name: 'Reverse', lat: lat, lon: lon);
}

void main() {
  test('falls over to the next provider when one fails', () async {
    final a = FakeProvider('A', failing: true);
    final b = FakeProvider('B');

    final report = await WeatherService([a, b]).fetchByCoords(1, 2);

    expect(report.source, 'B');
    expect(a.calls, 1);
  });

  test('tries the last working provider first, and parks failed ones', () async {
    final a = FakeProvider('A', failing: true);
    final b = FakeProvider('B');
    final service = WeatherService([a, b]);

    await service.fetchByCoords(1, 2);
    await service.fetchByCoords(1, 2);

    expect(a.calls, 1, reason: 'A is cooling down after failing');
    expect(b.calls, 2);
  });

  test('still tries providers in cooldown when everything else fails', () async {
    final a = FakeProvider('A', failing: true);
    final b = FakeProvider('B');
    final service = WeatherService([a, b]);
    await service.fetchByCoords(1, 2);

    b.failing = true;
    a.failing = false;
    final report = await service.fetchByCoords(1, 2);

    expect(report.source, 'A');
  });

  test('throws when every provider fails', () async {
    final service = WeatherService([FakeProvider('A', failing: true), FakeProvider('B', failing: true)]);

    expect(service.fetchByCity('Paris'), throwsA(isA<ProviderException>()));
  });

  test('geocodes cities for providers without city search', () async {
    final noCity = FakeProvider('NoCity', supportsCitySearch: false, placeName: '');
    final geocoder = FakeGeocoderProvider('Geo', failing: true);

    final report = await WeatherService([noCity, geocoder]).fetchByCity('Paris');

    expect(report.source, 'NoCity');
    expect(report.current.name, 'Geocoded Paris');
  });

  test('names coordinate results that come back without a place name', () async {
    final unnamed = FakeProvider('Unnamed', placeName: '');
    final geocoder = FakeGeocoderProvider('Geo', failing: true);

    final report = await WeatherService([unnamed, geocoder]).fetchByCoords(1, 2);

    expect(report.current.name, 'Reverse');
  });

  test('skips providers without an API key', () {
    expect(WeatherService.withDefaultProviders().providers.map((p) => p.name), isNot(contains('Tomorrow.io')));
  });

  test('dailyFromSeries groups readings by local day', () {
    // 00:00 UTC on 2 Nov 2026, readings every 6 hours for two days, UTC+1.
    final int start = DateTime.utc(2026, 11, 2).millisecondsSinceEpoch ~/ 1000;
    final series = List.generate(
      8,
      (i) => Weather(
        date: start + i * 6 * 3600,
        temperature: 280.0 + i,
        humidity: 50,
        windSpeed: '$i.0',
        condition: 800,
        description: 'clear',
      ),
    );

    final days = dailyFromSeries(series, timezone: 3600, sunrise: 1000, sunset: 2000);

    expect(days.length, 2); // local 01:00, 07:00, 13:00 and 19:00 on the 2nd and 3rd
    expect(days[0].tempMin, 280);
    expect(days[0].tempMax, 283);
    expect(days[1].windSpeed, '7.0');
    expect(days[1].sunrise, 1000 + 86400);
  });

  test('reports survive a round trip through the cache format', () {
    final report = WeatherReport(
      current: Weather(name: 'Oslo', temperature: 280.5, condition: 801, timezone: 3600),
      hourly: [Weather(date: 1, temperature: 281)],
      daily: [Weather(date: 2, tempMin: 279, tempMax: 283)],
      source: 'MET Norway',
      attribution: 'Weather data: MET Norway',
    );

    final copy = WeatherReport.fromJson(report.toJson());

    expect(copy.current.toString(), report.current.toString());
    expect(copy.daily.first.tempMax, 283);
    expect(copy.source, 'MET Norway');
  });
}
