import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvValidator {
  // List of required environment variables
  static const List<String> requiredVars = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
  ];

  // Optional environment variables with defaults
  static const Map<String, String> optionalVars = {
    'ENVIRONMENT': 'development',
    'APP_VERSION': '1.0.0',
  };

  /// Validates that all required environment variables are set
  static ValidationResult validate() {
    final List<String> missingVars = [];
    final Map<String, String> loadedVars = {};

    // Check required variables
    for (String varName in requiredVars) {
      final value = dotenv.env[varName];
      if (value == null || value.isEmpty) {
        missingVars.add(varName);
      } else {
        loadedVars[varName] = _maskSensitiveValue(varName, value);
      }
    }

    // Load optional variables with defaults
    for (String varName in optionalVars.keys) {
      final value = dotenv.env[varName] ?? optionalVars[varName]!;
      loadedVars[varName] = value;
    }

    return ValidationResult(
      isValid: missingVars.isEmpty,
      missingVariables: missingVars,
      loadedVariables: loadedVars,
    );
  }

  /// Masks sensitive values for logging/display
  static String _maskSensitiveValue(String varName, String value) {
    if (varName.contains('KEY') || varName.contains('SECRET')) {
      if (value.length <= 8) return '***';
      return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
    }
    return value;
  }

  /// Gets a specific environment variable with optional default
  static String getVar(String name, [String? defaultValue]) {
    return dotenv.env[name] ?? defaultValue ?? '';
  }

  /// Checks if we're in development mode
  static bool get isDevelopment => getVar('ENVIRONMENT') == 'development';

  /// Checks if we're in production mode
  static bool get isProduction => getVar('ENVIRONMENT') == 'production';

  /// Gets the app version
  static String get appVersion => getVar('APP_VERSION', '1.0.0');

  /// Prints environment validation results (for debugging)
  static void printValidationResults() {
    final result = validate();
    
    print('=== Environment Variables Validation ===');
    print('Status: ${result.isValid ? "✅ VALID" : "❌ INVALID"}');
    
    if (result.missingVariables.isNotEmpty) {
      print('\n❌ Missing Variables:');
      for (String varName in result.missingVariables) {
        print('  - $varName');
      }
    }
    
    if (result.loadedVariables.isNotEmpty) {
      print('\n✅ Loaded Variables:');
      result.loadedVariables.forEach((name, value) {
        print('  - $name: $value');
      });
    }
    
    print('==========================================\n');
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> missingVariables;
  final Map<String, String> loadedVariables;

  ValidationResult({
    required this.isValid,
    required this.missingVariables,
    required this.loadedVariables,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, missing: $missingVariables)';
  }
}
