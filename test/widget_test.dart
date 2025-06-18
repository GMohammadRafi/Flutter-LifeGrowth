// Tests for Life Growth app authentication flow

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifegrowth/screens/auth/login_screen.dart';
import 'package:lifegrowth/screens/auth/signup_screen.dart';
import 'package:lifegrowth/services/auth_service.dart';

void main() {
  group('Authentication Flow Tests', () {
    testWidgets('Login screen displays correctly', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Verify that login screen elements are present
      expect(find.text('Life Growth'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Signup screen displays correctly',
        (WidgetTester tester) async {
      // Build the signup screen
      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      // Verify that signup screen elements are present
      expect(find.text('Life Growth'), findsOneWidget);
      expect(find.text('Start Your Journey'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Navigation from login to signup works',
        (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Tap the Sign Up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify we're now on the signup screen
      expect(find.text('Start Your Journey'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Navigation from signup to login works',
        (WidgetTester tester) async {
      // Build the signup screen
      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify we're back on the login screen
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  group('AuthService Tests', () {
    test('AuthService initializes correctly', () {
      final authService = AuthService();

      // Test that the service can be created
      expect(authService, isNotNull);

      // Test initial state (should not be signed in without actual auth)
      expect(authService.isSignedIn, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.currentSession, isNull);
      expect(authService.hasValidSession, isFalse);
    });
  });
}
