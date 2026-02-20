import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para controlar la barra de estado
import 'screens/home_screen.dart';

void main() {
  // Esto hace que la barra de notificaciones del cel sea transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'SF Pro', // Si tienes la fuente, si no usa la default
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}