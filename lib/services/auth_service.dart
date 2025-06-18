import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Check if session is valid
  bool get hasValidSession => currentSession != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Refresh session
  Future<AuthResponse?> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response;
    } catch (e) {
      // If refresh fails, the session is likely invalid
      return null;
    }
  }

  // Initialize session (useful for app startup)
  Future<Session?> initializeSession() async {
    try {
      // Get the current session
      final session = _client.auth.currentSession;

      // If session exists but is expired, try to refresh it
      if (session != null && session.isExpired) {
        final refreshResponse = await refreshSession();
        return refreshResponse?.session;
      }

      return session;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _client.auth.updateUser(
        UserAttributes(data: updates),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
