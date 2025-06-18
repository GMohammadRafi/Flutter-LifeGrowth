class TaskCompletionModel {
  final String? id;
  final String taskId;
  final DateTime completionDate;
  final bool isCompleted;
  final DateTime createdAt;

  TaskCompletionModel({
    this.id,
    required this.taskId,
    required this.completionDate,
    this.isCompleted = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TaskCompletionModel.fromJson(Map<String, dynamic> json) {
    return TaskCompletionModel(
      id: json['id'] as String?,
      taskId: json['task_id'] as String,
      completionDate: DateTime.parse(json['completion_date'] as String),
      isCompleted: json['is_completed'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'completion_date': completionDate.toIso8601String().split('T')[0], // Date only
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'task_id': taskId,
      'completion_date': completionDate.toIso8601String().split('T')[0], // Date only
      'is_completed': isCompleted,
    };
  }

  TaskCompletionModel copyWith({
    String? id,
    String? taskId,
    DateTime? completionDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskCompletionModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      completionDate: completionDate ?? this.completionDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCompletionModel &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          completionDate == other.completionDate;

  @override
  int get hashCode => taskId.hashCode ^ completionDate.hashCode;
}
