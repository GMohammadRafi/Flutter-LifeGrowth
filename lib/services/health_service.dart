import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/health_model.dart';

class HealthService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'health_data';

  // Get health data for a specific date
  Future<HealthModel?> getHealthDataForDate(DateTime date) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final dateString = date.toIso8601String().split('T')[0];
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('date', dateString)
          .maybeSingle();

      return response != null ? HealthModel.fromJson(response) : null;
    } catch (e) {
      rethrow;
    }
  }

  // Get today's health data
  Future<HealthModel?> getTodaysHealthData() async {
    return await getHealthDataForDate(DateTime.now());
  }

  // Create or update health data for a specific date
  Future<HealthModel> saveHealthData(HealthModel healthData) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final dateString = healthData.date.toIso8601String().split('T')[0];
      
      // Check if data already exists for this date
      final existing = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('date', dateString)
          .maybeSingle();

      final dataToSave = healthData.toJson();
      dataToSave['user_id'] = userId;

      if (existing != null) {
        // Update existing record
        final response = await _client
            .from(_tableName)
            .update(dataToSave)
            .eq('user_id', userId)
            .eq('date', dateString)
            .select()
            .single();
        return HealthModel.fromJson(response);
      } else {
        // Create new record
        final response = await _client
            .from(_tableName)
            .insert(dataToSave)
            .select()
            .single();
        return HealthModel.fromJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update specific health metric
  Future<HealthModel> updateHealthMetric({
    DateTime? date,
    int? steps,
    int? waterGlasses,
    double? sleepHours,
    int? exerciseMinutes,
    double? weight,
    String? mood,
    String? notes,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final existing = await getHealthDataForDate(targetDate);
      
      final healthData = existing?.copyWith(
        steps: steps ?? existing.steps,
        waterGlasses: waterGlasses ?? existing.waterGlasses,
        sleepHours: sleepHours ?? existing.sleepHours,
        exerciseMinutes: exerciseMinutes ?? existing.exerciseMinutes,
        weight: weight ?? existing.weight,
        mood: mood ?? existing.mood,
        notes: notes ?? existing.notes,
      ) ?? HealthModel(
        date: targetDate,
        steps: steps,
        waterGlasses: waterGlasses,
        sleepHours: sleepHours,
        exerciseMinutes: exerciseMinutes,
        weight: weight,
        mood: mood,
        notes: notes,
      );

      return await saveHealthData(healthData);
    } catch (e) {
      rethrow;
    }
  }

  // Get health data for a date range
  Future<List<HealthModel>> getHealthDataRange(DateTime startDate, DateTime endDate) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final startDateString = startDate.toIso8601String().split('T')[0];
      final endDateString = endDate.toIso8601String().split('T')[0];

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .gte('date', startDateString)
          .lte('date', endDateString)
          .order('date', ascending: false);

      return (response as List)
          .map((data) => HealthModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get last 7 days of health data
  Future<List<HealthModel>> getLastWeekHealthData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    return await getHealthDataRange(startDate, endDate);
  }

  // Get last 30 days of health data
  Future<List<HealthModel>> getLastMonthHealthData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 29));
    return await getHealthDataRange(startDate, endDate);
  }

  // Get average steps for the last 7 days
  Future<double> getAverageStepsLastWeek() async {
    try {
      final data = await getLastWeekHealthData();
      final stepsData = data.where((d) => d.steps != null).map((d) => d.steps!);
      if (stepsData.isEmpty) return 0.0;
      return stepsData.reduce((a, b) => a + b) / stepsData.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Get average water intake for the last 7 days
  Future<double> getAverageWaterLastWeek() async {
    try {
      final data = await getLastWeekHealthData();
      final waterData = data.where((d) => d.waterGlasses != null).map((d) => d.waterGlasses!);
      if (waterData.isEmpty) return 0.0;
      return waterData.reduce((a, b) => a + b) / waterData.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Get average sleep for the last 7 days
  Future<double> getAverageSleepLastWeek() async {
    try {
      final data = await getLastWeekHealthData();
      final sleepData = data.where((d) => d.sleepHours != null).map((d) => d.sleepHours!);
      if (sleepData.isEmpty) return 0.0;
      return sleepData.reduce((a, b) => a + b) / sleepData.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Get total exercise minutes for the last 7 days
  Future<int> getTotalExerciseLastWeek() async {
    try {
      final data = await getLastWeekHealthData();
      final exerciseData = data.where((d) => d.exerciseMinutes != null).map((d) => d.exerciseMinutes!);
      if (exerciseData.isEmpty) return 0;
      return exerciseData.reduce((a, b) => a + b);
    } catch (e) {
      return 0;
    }
  }
}
