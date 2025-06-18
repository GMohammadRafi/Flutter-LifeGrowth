import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lifegrowth/screens/auth/auth_wrapper.dart';
import 'package:lifegrowth/config/supabase_config.dart';
import 'package:lifegrowth/utils/env_validator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Validate environment variables
    final validation = EnvValidator.validate();
    if (!validation.isValid) {
      throw Exception(
          'Missing required environment variables: ${validation.missingVariables.join(', ')}');
    }

    // Print validation results in debug mode
    if (EnvValidator.isDevelopment) {
      EnvValidator.printValidationResults();
    }

    // Initialize Supabase with environment variables
    await SupabaseConfig.initialize();

    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors
    runApp(ErrorApp(error: e.toString()));
  }
}

// Error app to show when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Growth - Error',
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF9F0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24B0BA),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your .env file and ensure all required environment variables are set.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      home: const AuthWrapper(),
    );
  }
}
