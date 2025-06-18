import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/habit_model.dart';

class HabitService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'habits';
  static const String _trackingTableName = 'habit_tracking';

  // Get all habits for the current user
  Future<List<HabitModel>> getHabits() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((habit) => HabitModel.fromJson(habit))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a new habit
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final habitData = habit.toJson();
      habitData['user_id'] = userId;

      final response = await _client
          .from(_tableName)
          .insert(habitData)
          .select()
          .single();

      return HabitModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update a habit
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .update(habit.toJson())
          .eq('id', habit.id)
          .eq('user_id', userId)
          .select()
          .single();

      return HabitModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a habit (mark as inactive)
  Future<void> deleteHabit(String habitId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from(_tableName)
          .update({'is_active': false})
          .eq('id', habitId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Mark habit as completed for today
  Future<void> markHabitCompleted(String habitId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if already completed today
      final existing = await _client
          .from(_trackingTableName)
          .select()
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .eq('date', dateString)
          .maybeSingle();

      if (existing == null) {
        // Insert new completion record
        await _client.from(_trackingTableName).insert({
          'habit_id': habitId,
          'user_id': userId,
          'date': dateString,
          'completed': true,
        });
      } else {
        // Update existing record
        await _client
            .from(_trackingTableName)
            .update({'completed': true})
            .eq('habit_id', habitId)
            .eq('user_id', userId)
            .eq('date', dateString);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Unmark habit completion for today
  Future<void> unmarkHabitCompleted(String habitId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _client
          .from(_trackingTableName)
          .update({'completed': false})
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .eq('date', dateString);
    } catch (e) {
      rethrow;
    }
  }

  // Check if habit is completed today
  Future<bool> isHabitCompletedToday(String habitId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _client
          .from(_trackingTableName)
          .select()
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .eq('date', dateString)
          .eq('completed', true)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get habit streak (consecutive days completed)
  Future<int> getHabitStreak(String habitId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get last 30 days of tracking data
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final response = await _client
          .from(_trackingTableName)
          .select()
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .eq('completed', true)
          .gte('date', thirtyDaysAgo.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      if (response.isEmpty) return 0;

      // Calculate streak
      int streak = 0;
      final today = DateTime.now();
      
      for (int i = 0; i < 30; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final dateString = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        
        final completed = response.any((record) => record['date'] == dateString);
        
        if (completed) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  // Get habit completion rate for the last 30 days
  Future<double> getHabitCompletionRate(String habitId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final response = await _client
          .from(_trackingTableName)
          .select()
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .gte('date', thirtyDaysAgo.toIso8601String().split('T')[0]);

      if (response.isEmpty) return 0.0;

      final completedDays = response.where((record) => record['completed'] == true).length;
      return completedDays / 30.0;
    } catch (e) {
      return 0.0;
    }
  }
}
