import '../services/weather_service.dart';
import 'package:flutter/material.dart';
import '../widgets/forecast_item.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

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
  String? iconCode;
  String? errorMessage;
  bool isLoading = false;
  List<dynamic>? forecastList;

  // Lógica de colores dinámicos según el clima seguro
  List<Color> _getBackgroundColors() {
    if (iconCode == null) return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
    
    switch (iconCode) {
      case '01d': return [const Color(0xFFFF8008), const Color(0xFFFFC837)]; // Sol
      case '01n': return [const Color(0xFF0F2027), const Color(0xFF2C5364)]; // Noche
      case '02d': case '02n': case '03d': case '04d': 
        return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)]; // Nubes
      case '09d': case '10d': return [const Color(0xFF373B44), const Color(0xFF4286f4)]; // Lluvia
      case '11d': return [const Color(0xFF4B79A1), const Color(0xFF283E51)]; // Tormenta
      case '13d': return [const Color(0xFF83a4d4), const Color(0xFFb6fbff)]; // Nieve
      default: return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
    }
  }

  String _getDayName(String dateTxt) {
    DateTime date = DateTime.parse(dateTxt);
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }

  void _updateUI(dynamic weather, dynamic forecast) {
    if (weather != null && forecast != null) {
      setState(() {
        temperature = weather["main"]["temp"].toStringAsFixed(0);
        description = weather["weather"][0]["description"];
        cityName = weather["name"];
        iconCode = weather["weather"][0]["icon"];
        forecastList = forecast;
        errorMessage = null;
      });
    } else {
      setState(() => errorMessage = "No se encontraron datos");
    }
  }

  // --- LÓGICA DE CLIMA POR BUSQUEDA ---
  void getWeather() async {
    if (_controller.text.isEmpty) return;
    FocusScope.of(context).unfocus(); 
    setState(() => isLoading = true);
    final weather = await _weatherService.fetchWeather(_controller.text);
    final forecast = await _weatherService.fetchForecast(_controller.text);
    _updateUI(weather, forecast);
    setState(() => isLoading = false);
  }

  // --- LÓGICA DE UBICACIÓN (CON PERMISOS) ---
  Future<void> getLocationWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Verificar si el servicio de GPS está activo
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'El GPS está desactivado';
      }

      // Verificar y pedir permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permiso de ubicación denegado';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Permisos denegados permanentemente';
      }

      // Obtener posición y datos
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      final weather = await _weatherService.fetchWeatherByCoords(position.latitude, position.longitude);
      final forecast = await _weatherService.fetchForecastByCoords(position.latitude, position.longitude);
      
      _updateUI(weather, forecast);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo Animado
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getBackgroundColors(),
              ),
            ),
          ),
          // Brillo de cristal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // BUSCADOR PREMIUM
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          controller: _controller,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            hintText: "Buscar ciudad...",
                            hintStyle: const TextStyle(color: Colors.white60, fontSize: 18),
                            border: InputBorder.none,
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.location_searching, color: Colors.white70),
                              onPressed: getLocationWeather,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search, color: Colors.white, size: 28),
                              onPressed: getWeather,
                            ),
                          ),
                          onSubmitted: (_) => getWeather(),
                        ),
                      ),
                    ),
                  ),
                ),

                if (isLoading) 
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white))),

                if (!isLoading && temperature != null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Column(
                        children: [
                          Text(cityName ?? "", style: const TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.w400)),
                          Text("$temperature°", style: const TextStyle(fontSize: 100, color: Colors.white, fontWeight: FontWeight.w100)),
                          Text(description!.toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 3, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Image.network("https://openweathermap.org/img/wn/$iconCode@4x.png", height: 160),
                          const SizedBox(height: 30),
                          // TARJETA PRONÓSTICO
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                color: Colors.white.withOpacity(0.1),
                                child: Column(
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.calendar_month, color: Colors.white60, size: 16),
                                      const SizedBox(width: 10),
                                      Text("PRONÓSTICO 5 DÍAS", style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ]),
                                    const Divider(color: Colors.white24, height: 30),
                                    SizedBox(
                                      height: 110,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 5,
                                        itemBuilder: (context, index) {
                                          final item = forecastList![index * 8];
                                          return ForecastItem(
                                            date: _getDayName(item["dt_txt"]),
                                            temperature: item["main"]["temp"].toStringAsFixed(0),
                                            icon: item["weather"][0]["icon"],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (errorMessage != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                
                if (temperature == null && !isLoading && errorMessage == null)
                  const Expanded(
                    child: Center(child: Text("Busca una ciudad o usa tu ubicación", style: TextStyle(color: Colors.white70, fontSize: 16))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}