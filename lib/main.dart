import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Growth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF73C7E3),
          primary: const Color(0xFF73C7E3), // Light blue
          secondary: const Color(0xFF24B0BA), // Teal
          surface: const Color(0xFFFFF9F0), // Warm off-white background
        ),
        scaffoldBackgroundColor:
            const Color(0xFFFFF9F0), // Warm off-white background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF73C7E3), // Light blue app bar
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF24B0BA), // Teal for titles
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF333333), // Dark text for readability
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF333333), // Dark text for readability
          ),
        ),
        useMaterial3: true,
      ),
      home: DashboardScreen(),
    );
  }
}
