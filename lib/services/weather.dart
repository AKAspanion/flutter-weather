class Weather {
  int date;
  int sunset;
  int sunrise;
  String name;
  int timezone;
  int humidity;
  int condition;
  double latitude;
  double longitude;
  String windSpeed;
  double tempMin;
  double tempMax;
  double temperature;
  String description;

  Weather({
    this.name,
    this.date,
    this.sunset,
    this.sunrise,
    this.timezone,
    this.humidity,
    this.condition,
    this.latitude,
    this.longitude,
    this.windSpeed,
    this.tempMin,
    this.tempMax,
    this.temperature,
    this.description,
  });

  String getIcon({String overrideNight}) {
    DateTime now = DateTime.now().toUtc();
    DateTime zoneTime = now.add(Duration(seconds: timezone ?? 0));
    String night = zoneTime.hour > 18 || zoneTime.hour <= 6 ? "-night" : "";

    if (overrideNight != null) {
      night = overrideNight;
    }

    if (condition >= 200 && condition < 300) {
      return "thunder";
    } else if (condition >= 300 && condition <= 321) {
      return "rain";
    } else if (condition >= 500 && condition <= 504) {
      return "rain";
    } else if (condition >= 600 && condition <= 622) {
      return "snow";
    } else if (condition == 800) {
      return "clear" + night;
    } else if (condition == 801) {
      return "sunny" + night;
    } else if (condition == 741) {
      return "foggy";
    } else if (condition == 803 || condition == 804) {
      return "broken";
    } else {
      return "few" + night;
    }
  }

  @override
  String toString() {
    final String data1 =
        'name: $name, description: $description, condition: $condition, temperature: $temperature';
    final String data2 =
        'humidity: $humidity, sunrise: $sunrise, sunset: $sunset, date: $date, min: $tempMin, max: $tempMax';
    return 'Weather($data1, $data2, windSpeed: $windSpeed, timezone: $timezone, latitude: $latitude, longitude $longitude)';
  }
}
