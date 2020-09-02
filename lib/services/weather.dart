class Weather {
  String name;
  int sunset;
  int sunrise;
  int humidity;
  int condition;
  String windSpeed;
  double temperature;
  String description;

  Weather({
    this.name,
    this.sunset,
    this.sunrise,
    this.humidity,
    this.condition,
    this.windSpeed,
    this.temperature,
    this.description,
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
      return "rain";
    } else {
      return "few";
    }
  }

  @override
  String toString() {
    final String data1 =
        'name: $name, description: $description, condition: $condition, temperature: $temperature';
    final String data2 =
        'humidity: $humidity, sunrise: $sunrise, sunset: $sunset';
    return 'Weather($data1, $data2, windSpeed: $windSpeed)';
  }
}
