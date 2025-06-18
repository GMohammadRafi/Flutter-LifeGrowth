import 'category_model.dart';
import 'schedule_type_model.dart';

class EnhancedTaskModel {
  final String? id;
  final String? userId;
  final String name;
  final String? categoryId;
  final String? scheduleTypeId;
  final DateTime? dueDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related objects (populated when joining tables)
  final CategoryModel? category;
  final ScheduleTypeModel? scheduleType;

  EnhancedTaskModel({
    this.id,
    this.userId,
    required this.name,
    this.categoryId,
    this.scheduleTypeId,
    this.dueDate,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.category,
    this.scheduleType,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EnhancedTaskModel.fromJson(Map<String, dynamic> json) {
    return EnhancedTaskModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      categoryId: json['category_id'] as String?,
      scheduleTypeId: json['schedule_type_id'] as String?,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String)
          : null,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['categories'] != null 
          ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      scheduleType: json['schedule_types'] != null 
          ? ScheduleTypeModel.fromJson(json['schedule_types'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category_id': categoryId,
      'schedule_type_id': scheduleTypeId,
      'due_date': dueDate?.toIso8601String(),
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = <String, dynamic>{
      'name': name,
      'category_id': categoryId,
      'schedule_type_id': scheduleTypeId,
      'due_date': dueDate?.toIso8601String().split('T')[0], // Date only
      'notes': notes,
      'is_active': isActive,
    };
    
    // Remove null values
    json.removeWhere((key, value) => value == null);
    return json;
  }

  EnhancedTaskModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? categoryId,
    String? scheduleTypeId,
    DateTime? dueDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryModel? category,
    ScheduleTypeModel? scheduleType,
  }) {
    return EnhancedTaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      scheduleTypeId: scheduleTypeId ?? this.scheduleTypeId,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      scheduleType: scheduleType ?? this.scheduleType,
    );
  }

  @override
  String toString() => name;
}
