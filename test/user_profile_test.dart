import 'package:flutter_test/flutter_test.dart';
import 'package:lifegrowth/models/user_profile_model.dart';

void main() {
  group('UserProfileModel Tests', () {
    test('should create UserProfileModel from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'test-user-id',
        'full_name': 'John Doe',
        'avatar_url': 'https://example.com/avatar.jpg',
        'date_of_birth': '1990-01-01',
        'timezone': 'America/New_York',
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-01T00:00:00.000Z',
      };

      // Act
      final profile = UserProfileModel.fromJson(json);

      // Assert
      expect(profile.id, equals('test-user-id'));
      expect(profile.fullName, equals('John Doe'));
      expect(profile.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(profile.dateOfBirth, equals(DateTime.parse('1990-01-01')));
      expect(profile.timezone, equals('America/New_York'));
    });

    test('should convert UserProfileModel to JSON correctly', () {
      // Arrange
      final profile = UserProfileModel(
        id: 'test-user-id',
        fullName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        dateOfBirth: DateTime.parse('1990-01-01'),
        timezone: 'America/New_York',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      // Act
      final json = profile.toJson();

      // Assert
      expect(json['id'], equals('test-user-id'));
      expect(json['full_name'], equals('John Doe'));
      expect(json['avatar_url'], equals('https://example.com/avatar.jpg'));
      expect(json['date_of_birth'], equals('1990-01-01'));
      expect(json['timezone'], equals('America/New_York'));
      expect(json['created_at'], equals('2023-01-01T00:00:00.000Z'));
    });

    test('should handle null values correctly', () {
      // Arrange
      final json = {
        'id': 'test-user-id',
        'full_name': null,
        'avatar_url': null,
        'date_of_birth': null,
        'timezone': 'UTC',
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-01T00:00:00.000Z',
      };

      // Act
      final profile = UserProfileModel.fromJson(json);

      // Assert
      expect(profile.id, equals('test-user-id'));
      expect(profile.fullName, isNull);
      expect(profile.avatarUrl, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(profile.timezone, equals('UTC'));
    });

    test('should create copy with updated fields', () {
      // Arrange
      final originalProfile = UserProfileModel(
        id: 'test-user-id',
        fullName: 'John Doe',
        timezone: 'UTC',
      );

      // Act
      final updatedProfile = originalProfile.copyWith(
        fullName: 'Jane Doe',
        timezone: 'America/New_York',
      );

      // Assert
      expect(updatedProfile.id, equals('test-user-id'));
      expect(updatedProfile.fullName, equals('Jane Doe'));
      expect(updatedProfile.timezone, equals('America/New_York'));
      expect(updatedProfile.avatarUrl, equals(originalProfile.avatarUrl));
      expect(updatedProfile.dateOfBirth, equals(originalProfile.dateOfBirth));
    });

    test('should have correct equality comparison', () {
      // Arrange
      final profile1 = UserProfileModel(
        id: 'test-user-id',
        fullName: 'John Doe',
        timezone: 'UTC',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final profile2 = UserProfileModel(
        id: 'test-user-id',
        fullName: 'John Doe',
        timezone: 'UTC',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final profile3 = UserProfileModel(
        id: 'different-user-id',
        fullName: 'John Doe',
        timezone: 'UTC',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      // Assert
      expect(profile1, equals(profile2));
      expect(profile1, isNot(equals(profile3)));
      expect(profile1.hashCode, equals(profile2.hashCode));
    });
  });
}
