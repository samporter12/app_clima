import '../services/weather_service.dart';
import 'package:flutter/material.dart';
import '../widgets/forecast_item.dart';
import  'package:geolocator/geolocator.dart';                      
class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

    Future<void> getLocationWeather() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
        return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
        return;
        }
    }

    if (permission == LocationPermission.deniedForever) {
        return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
    );

    final weatherData = await _weatherService.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
    );

    final forecastData = await _weatherService.fetchForecastByCoords(
        position.latitude,
        position.longitude,
    );

    if (weatherData != null && forecastData != null) {
        setState(() {
        temperature = weatherData["main"]["temp"].toString();
        description = weatherData["weather"][0]["description"];
        cityName = weatherData["name"];
        iconCode = weatherData["weather"][0]["icon"];
        forecastList = forecastData;
        });
    }
    }

    final TextEditingController _controller = TextEditingController();
    final WeatherService _weatherService = WeatherService();

    String? temperature;
    String? description;
    String? cityName;
    String? iconCode;
    String? errorMessage;
    bool isLoading = false;

    List<dynamic>? forecastList;

    void getWeather() async {

    setState(() {
        isLoading = true;
        errorMessage = null;
    });

    final weatherData =
        await _weatherService.fetchWeather(_controller.text);

    final forecastData =
        await _weatherService.fetchForecast(_controller.text);

    setState(() {
        isLoading = false;
    });

    if (weatherData != null && forecastData != null) {
        setState(() {
            temperature = weatherData["main"]["temp"].toString();
            description = weatherData["weather"][0]["description"];
            cityName = weatherData["name"];
            iconCode = weatherData["weather"][0]["icon"];
            forecastList = forecastData;
        });
    } else {
        setState(() {
            errorMessage = "Error al obtener datos";
        });
    }

}

    @override
    Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: const Text("App del Clima"),
            centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
            child: Column(
                children: [

                TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        labelText: "Escribe una ciudad",
                        border: OutlineInputBorder(),
                ),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                    onPressed: getWeather,
                    child: const Text("Buscar"),
                ),

                const SizedBox(height: 10),

                    ElevatedButton.icon(
                    onPressed: getLocationWeather,
                    icon: const Icon(Icons.location_on),
                    label: const Text("Usar mi ubicación"),
                    ),


                const SizedBox(height: 20),

                if (isLoading)
                    const CircularProgressIndicator(),

                if (errorMessage != null)
                    Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                ),

                if (temperature != null)
                    Column(
                        children: [

                    if (iconCode != null)
                        Image.network(
                            "https://openweathermap.org/img/wn/$iconCode@2x.png",
                        ),

                    Text(
                        cityName ?? "",
                        style: const TextStyle(fontSize: 22),
                    ),

                    Text(
                        "$temperature °C",
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                    ),

                    Text(
                        description ?? "",
                        style: const TextStyle(fontSize: 18),
                        ),
                    ],
                ),

                const SizedBox(height: 20),

              // PRONÓSTICO 5 DÍAS
                if (forecastList != null)
                SizedBox(
                    height: 120,
                    child: Center(
                    child: ListView.builder(
                        shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {

                        final item = forecastList![index * 8];

                        final date = item["dt_txt"].substring(5, 10);
                        final temp = item["main"]["temp"].toString();
                        final icon = item["weather"][0]["icon"];

                        return ForecastItem(
                            date: date,
                            temperature: temp,
                            icon: icon,
                        );
                    },
                    ),
                ),
                ),
            ],
            ),
        ),
        ),
    );
    }
}
