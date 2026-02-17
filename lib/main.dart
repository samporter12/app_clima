import 'package:flutter/material.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  String? temperature;
  String? description;
  String? cityName;
  bool isLoading = false;
  String? errorMessage;

  void getWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final data = await _weatherService.fetchWeather(_controller.text);

    setState(() {
      isLoading = false;
    });

    if (data != null) {
      setState(() {
        temperature = data["main"]["temp"].toString();
        description = data["weather"][0]["description"];
        cityName = data["name"];
      });
    } else {
      setState(() {
        errorMessage = "Ciudad no encontrada";
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

            const SizedBox(height: 30),

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
          ],
        ),
      ),
    );
  }
}
