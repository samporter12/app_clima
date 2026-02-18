import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';  

class WeatherService {

  Future<Map<String, dynamic>?> fetchWeather(String city) async {

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=es"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

    Future<List<dynamic>?> fetchForecast(String city) async {

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=es"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["list"];
    } else {
      return null;
    }
  }
Future<Map<String, dynamic>?> fetchWeatherByCoords(
    double lat, double lon) async {

  final url = Uri.parse(
    "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es"
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

Future<List<dynamic>?> fetchForecastByCoords(
    double lat, double lon) async {

  final url = Uri.parse(
    "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es"
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["list"];
  } else {
    return null;
  }
}
}





