class ScheduleTypeModel {
  final String id;
  final String name;
  final DateTime createdAt;

  ScheduleTypeModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ScheduleTypeModel.fromJson(Map<String, dynamic> json) {
    return ScheduleTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTypeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
