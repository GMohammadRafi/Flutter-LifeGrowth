import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/task_model.dart';

class TaskService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'tasks';

  // Get all tasks for the current user
  Future<List<TaskModel>> getTasks() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final taskData = task.toJson();
      taskData['user_id'] = userId;

      final response = await _client
          .from(_tableName)
          .insert(taskData)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update a task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .update(task.toJson())
          .eq('id', task.id)
          .eq('user_id', userId)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from(_tableName)
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Toggle task completion
  Future<TaskModel> toggleTaskCompletion(String taskId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // First get the current task
      final currentTask = await _client
          .from(_tableName)
          .select()
          .eq('id', taskId)
          .eq('user_id', userId)
          .single();

      final task = TaskModel.fromJson(currentTask);
      
      // Toggle completion
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );

      return await updateTask(updatedTask);
    } catch (e) {
      rethrow;
    }
  }

  // Get tasks by status
  Future<List<TaskModel>> getTasksByStatus(bool isCompleted) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', isCompleted)
          .order('created_at', ascending: false);

      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get tasks due today
  Future<List<TaskModel>> getTasksDueToday() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .gte('due_date', startOfDay.toIso8601String())
          .lt('due_date', endOfDay.toIso8601String())
          .order('due_date', ascending: true);

      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search tasks
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
