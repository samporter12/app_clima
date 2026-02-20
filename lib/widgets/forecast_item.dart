import 'package:flutter/material.dart';

class ForecastItem extends StatelessWidget {
  final String date;
  final String temperature;
  final String icon;

  const ForecastItem({
    super.key,
    required this.date,
    required this.temperature,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Un poco más estrecho para que quepan más
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          Image.network(
            "https://openweathermap.org/img/wn/$icon.png",
            width: 45,
          ),
          const SizedBox(height: 5),
          Text(
            "$temperature°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}