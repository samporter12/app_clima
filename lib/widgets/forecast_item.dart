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
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(date),
          Image.network(
            "https://openweathermap.org/img/wn/$icon.png",
          ),
          Text("$temperature °C"),
        ],
      ),
    );
  }
}
