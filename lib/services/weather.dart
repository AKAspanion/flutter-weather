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
    DateTime now = DateTime.now();
    String night = now.hour > 18 && now.hour <= 0 ? "night" : "";

    if (condition >= 200 && condition < 300) {
      return "thunder";
    } else if (condition >= 300 && condition <= 321) {
      return "rain";
    } else if (condition == 800) {
      return "clear" + night;
    } else if (condition == 801) {
      return "sunny" + night;
    } else if (condition == 803 || condition == 804) {
      return "broken";
    } else if (condition >= 500 && condition <= 504) {
      return "rain";
    } else {
      return "few" + night;
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
