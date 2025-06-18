import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/enhanced_task_model.dart';
import '../models/category_model.dart';
import '../models/schedule_type_model.dart';
import '../models/task_completion_model.dart';

class EnhancedTaskService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((category) => CategoryModel.fromJson(category))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Schedule Types
  Future<List<ScheduleTypeModel>> getScheduleTypes() async {
    try {
      final response = await _client
          .from('schedule_types')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((scheduleType) => ScheduleTypeModel.fromJson(scheduleType))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Tasks
  Future<List<EnhancedTaskModel>> getTasks() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('enhanced_tasks')
          .select('''
            *,
            categories(*),
            schedule_types(*)
          ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((task) => EnhancedTaskModel.fromJson(task))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<EnhancedTaskModel> createTask(EnhancedTaskModel task) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final taskData = task.toInsertJson();
      taskData['user_id'] = userId;

      final response =
          await _client.from('enhanced_tasks').insert(taskData).select('''
            *,
            categories(*),
            schedule_types(*)
          ''').single();

      return EnhancedTaskModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<EnhancedTaskModel> updateTask(EnhancedTaskModel task) async {
    try {
      if (task.id == null) throw Exception('Task ID is required for update');

      final response = await _client
          .from('enhanced_tasks')
          .update(task.toInsertJson())
          .eq('id', task.id!)
          .select('''
            *,
            categories(*),
            schedule_types(*)
          ''').single();

      return EnhancedTaskModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from('enhanced_tasks').delete().eq('id', taskId);
    } catch (e) {
      rethrow;
    }
  }

  // Task Completions
  Future<TaskCompletionModel> markTaskComplete(
      String taskId, DateTime date) async {
    try {
      final completion = TaskCompletionModel(
        taskId: taskId,
        completionDate: date,
        isCompleted: true,
      );

      final response = await _client
          .from('task_completions')
          .upsert(completion.toInsertJson())
          .select()
          .single();

      return TaskCompletionModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markTaskIncomplete(String taskId, DateTime date) async {
    try {
      await _client
          .from('task_completions')
          .delete()
          .eq('task_id', taskId)
          .eq('completion_date', date.toIso8601String().split('T')[0]);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TaskCompletionModel>> getTaskCompletions(String taskId) async {
    try {
      final response = await _client
          .from('task_completions')
          .select()
          .eq('task_id', taskId)
          .order('completion_date', ascending: false);

      return (response as List)
          .map((completion) => TaskCompletionModel.fromJson(completion))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Streak calculation
  Future<int> calculateStreak(String taskId) async {
    try {
      final completions = await getTaskCompletions(taskId);
      if (completions.isEmpty) return 0;

      // Sort by date descending
      completions.sort((a, b) => b.completionDate.compareTo(a.completionDate));

      int streak = 0;
      DateTime currentDate = DateTime.now();

      // Start from today and go backwards
      for (int i = 0; i < 365; i++) {
        // Max 365 days check
        final checkDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day - i,
        );

        final hasCompletion = completions.any((completion) =>
            completion.completionDate.year == checkDate.year &&
            completion.completionDate.month == checkDate.month &&
            completion.completionDate.day == checkDate.day);

        if (hasCompletion) {
          streak++;
        } else if (i > 0) {
          // Don't break on first day (today) if not completed
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  // Get tasks due today
  Future<List<EnhancedTaskModel>> getTasksDueToday() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final todayString = DateTime(today.year, today.month, today.day)
          .toIso8601String()
          .split('T')[0];

      final response = await _client
          .from('enhanced_tasks')
          .select('''
            *,
            categories(*),
            schedule_types(*)
          ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .eq('due_date', todayString)
          .order('created_at', ascending: false);

      return (response as List)
          .map((task) => EnhancedTaskModel.fromJson(task))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Check if task is completed today
  Future<bool> isTaskCompletedToday(String taskId) async {
    try {
      final today = DateTime.now();
      final todayString = DateTime(today.year, today.month, today.day)
          .toIso8601String()
          .split('T')[0];

      final response = await _client
          .from('task_completions')
          .select()
          .eq('task_id', taskId)
          .eq('completion_date', todayString)
          .eq('is_completed', true);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
