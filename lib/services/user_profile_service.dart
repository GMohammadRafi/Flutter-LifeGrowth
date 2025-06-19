import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'user_profiles';

  // Get current user's profile
  Future<UserProfileModel?> getCurrentUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response != null ? UserProfileModel.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile (usually called after signup)
  Future<UserProfileModel> createUserProfile(UserProfileModel profile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final profileData = profile.toJson();
      profileData['id'] = userId; // Ensure the profile ID matches the user ID

      final response =
          await _client.from(_tableName).insert(profileData).select().single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final profileData = profile.toJson();
      profileData.remove('id'); // Don't update the ID
      profileData.remove('created_at'); // Don't update created_at

      final response = await _client
          .from(_tableName)
          .update(profileData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update specific profile fields
  Future<UserProfileModel> updateProfileFields({
    String? fullName,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? timezone,
    double? heightCm,
    String? heightUnit,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (dateOfBirth != null) {
        updates['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (timezone != null) updates['timezone'] = timezone;
      if (heightCm != null) updates['height_cm'] = heightCm;
      if (heightUnit != null) updates['height_unit'] = heightUnit;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete user profile (usually not needed, but included for completeness)
  Future<void> deleteUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from(_tableName).delete().eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile by ID (for admin purposes or viewing other users)
  Future<UserProfileModel?> getUserProfileById(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response != null ? UserProfileModel.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }
}
