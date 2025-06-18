class HealthModel {
  final String? id;
  final String? userId;
  final DateTime date;
  final int? steps;
  final int? waterGlasses;
  final double? sleepHours;
  final int? exerciseMinutes;
  final double? weight;
  final String? mood; // 'excellent', 'good', 'okay', 'poor', 'terrible'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthModel({
    this.id,
    this.userId,
    DateTime? date,
    this.steps,
    this.waterGlasses,
    this.sleepHours,
    this.exerciseMinutes,
    this.weight,
    this.mood,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create HealthModel from JSON (from Supabase)
  factory HealthModel.fromJson(Map<String, dynamic> json) {
    return HealthModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      steps: json['steps']?.toInt(),
      waterGlasses: json['water_glasses']?.toInt(),
      sleepHours: json['sleep_hours']?.toDouble(),
      exerciseMinutes: json['exercise_minutes']?.toInt(),
      weight: json['weight']?.toDouble(),
      mood: json['mood'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  // Convert HealthModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'steps': steps,
      'water_glasses': waterGlasses,
      'sleep_hours': sleepHours,
      'exercise_minutes': exerciseMinutes,
      'weight': weight,
      'mood': mood,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create a copy of HealthModel with updated fields
  HealthModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? steps,
    int? waterGlasses,
    double? sleepHours,
    int? exerciseMinutes,
    double? weight,
    String? mood,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      waterGlasses: waterGlasses ?? this.waterGlasses,
      sleepHours: sleepHours ?? this.sleepHours,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      weight: weight ?? this.weight,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HealthModel(id: $id, date: $date, steps: $steps, mood: $mood)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
