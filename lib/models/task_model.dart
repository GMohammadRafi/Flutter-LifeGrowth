class TaskModel {
  final String? id;
  final String? userId;
  final String title;
  final String description;
  final String priority; // 'High', 'Medium', 'Low'
  final String category;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    this.priority = 'Medium',
    this.category = 'General',
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create TaskModel from JSON (from Supabase)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      category: json['category'] ?? 'General',
      isCompleted: json['is_completed'] ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  // Convert TaskModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create a copy of TaskModel with updated fields
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? priority,
    String? category,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
