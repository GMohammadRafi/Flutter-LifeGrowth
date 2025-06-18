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
          .from('tasks')
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

      final response = await _client.from('tasks').insert(taskData).select('''
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
          .from('tasks')
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
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      rethrow;
    }
  }

  // Task Completions - Simplified version that works around auth issues
  Future<TaskCompletionModel> markTaskComplete(
      String taskId, DateTime date) async {
    try {
      print('DEBUG: Attempting to mark task complete (simplified)');
      print('  Task ID: $taskId');
      print('  Date: $date');

      // Simplified approach - just check if task exists (no user validation for now)
      final taskExists = await _client
          .from('tasks')
          .select('id, name')
          .eq('id', taskId)
          .maybeSingle();

      if (taskExists == null) {
        print('  ERROR: Task $taskId not found in database');

        // Let's see what tasks DO exist
        final allTasks =
            await _client.from('tasks').select('id, name').limit(5);

        print('  Available tasks:');
        for (final task in allTasks) {
          print('    - ${task['id']}: ${task['name']}');
        }

        throw Exception('Task not found with ID: $taskId');
      }

      print('  Task found: ${taskExists['name']}');

      // Create completion record (simplified)
      final completionData = {
        'task_id': taskId,
        'completion_date': date.toIso8601String().split('T')[0], // Date only
        'is_completed': true,
      };

      print('  Inserting completion data: $completionData');

      // Try to insert/update the completion
      final response = await _client
          .from('task_completions')
          .upsert(completionData)
          .select()
          .single();

      print('  Success! Completion created: ${response['id']}');
      return TaskCompletionModel.fromJson(response);
    } catch (e) {
      print('ERROR in markTaskComplete:');
      print('  Task ID: $taskId');
      print('  Date: $date');
      print('  Error: $e');
      print('  Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> markTaskIncomplete(String taskId, DateTime date) async {
    try {
      // Verify user authentication
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('task_completions')
          .delete()
          .eq('task_id', taskId)
          .eq('completion_date', date.toIso8601String().split('T')[0]);
    } catch (e) {
      print('Error in markTaskIncomplete: $e');
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
          .from('tasks')
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
