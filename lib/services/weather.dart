class Weather {
  String name;
  String icon;
  int condition;
  int humidity;
  double windSpeed;
  int sunrise;
  int sunset;
  double temperature;

  Weather({
    this.name,
    this.icon,
    this.condition,
    this.temperature,
    this.humidity,
    this.sunrise,
    this.sunset,
    this.windSpeed,
  });

  String getIcon() {
    if (condition >= 200 && condition < 300) {
      return "thunder";
    } else if (condition >= 300 && condition <= 321) {
      return "rain";
    } else if (condition == 800) {
      return "clear";
    } else if (condition == 801) {
      return "sunny";
    } else if (condition == 803 || condition == 804) {
      return "broken";
    } else if (condition >= 500 && condition <= 504) {
      return "few";
    } else {
      return "clouds";
    }
  }

  @override
  String toString() {
    final String data1 =
        'name: $name, condition: $condition, temperature: $temperature';
    final String data2 =
        'humidity: $humidity, sunrise: $sunrise, sunset: $sunset';
    return 'Weather($data1, $data2, windSpeed: $windSpeed, icon: $icon)';
  }
}
