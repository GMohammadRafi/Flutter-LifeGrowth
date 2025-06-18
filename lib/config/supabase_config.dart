import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Get Supabase credentials from environment variables
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static Future<void> initialize() async {
    // Validate that required environment variables are set
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'Supabase credentials not found in environment variables. '
          'Please check your .env file and ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug:
          environment == 'development', // Enable debug mode only in development
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Helper method to check if configuration is valid
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
