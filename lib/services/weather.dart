class Weather {
  String name;
  String icon;
  int condition;
  int humidity;
  double windSpeed;
  int sunrise;
  int sunset;
  double temperature;

  Weather(
      {this.name,
      this.icon,
      this.condition,
      this.temperature,
      this.humidity,
      this.sunrise,
      this.sunset,
      this.windSpeed});

  @override
  String toString() {
    final String data1 =
        'name: $name, condition: $condition, temperature: $temperature';
    final String data2 =
        'humidity: $humidity, sunrise: $sunrise, sunset: $sunset';
    return 'Weather($data1, $data2, windSpeed: $windSpeed, icon: $icon)';
  }
}
