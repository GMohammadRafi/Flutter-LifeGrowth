import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Session? _currentSession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _setupAuthListener();
  }

  void _initializeAuth() {
    // Get initial session
    _currentSession = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isLoading = false;
    });
  }

  void _setupAuthListener() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthState authState = data;
      final Session? newSession = authState.session;

      // Update session state
      if (mounted && newSession != _currentSession) {
        setState(() {
          _currentSession = newSession;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth state
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF9F0),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF24B0BA),
          ),
        ),
      );
    }

    // Check if user is authenticated
    if (_currentSession != null) {
      // User is authenticated, show main app
      return const DashboardScreen();
    } else {
      // User is not authenticated, show login screen
      return const LoginScreen();
    }
  }
}
