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
 primaryColor: const Color(0xFF73C7E3), // Primary color (deprecated, use colorScheme.primary)
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), // Use titleLarge instead of headline6
        ),
      ),
      home: DashboardScreen(),
    );
  }
}
