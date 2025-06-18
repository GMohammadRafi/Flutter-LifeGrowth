class HabitModel {
  final String? id;
  final String? userId;
  final String title;
  final String description;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final String category;
  final bool isActive;
  final String? reminderTime; // Time in HH:MM format
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    this.frequency = 'daily',
    this.category = 'Health',
    this.isActive = true,
    this.reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create HabitModel from JSON (from Supabase)
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frequency: json['frequency'] ?? 'daily',
      category: json['category'] ?? 'Health',
      isActive: json['is_active'] ?? true,
      reminderTime: json['reminder_time'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  // Convert HabitModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'description': description,
      'frequency': frequency,
      'category': category,
      'is_active': isActive,
      'reminder_time': reminderTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create a copy of HabitModel with updated fields
  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? frequency,
    String? category,
    bool? isActive,
    String? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, title: $title, frequency: $frequency, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
