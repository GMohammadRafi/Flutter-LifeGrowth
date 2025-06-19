class UserProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String timezone;
  final double? heightCm; // Height stored in centimeters
  final String heightUnit; // Preferred display unit (cm, ft, m)
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.timezone = 'UTC',
    this.heightCm,
    this.heightUnit = 'cm',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create UserProfileModel from JSON (from Supabase)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      timezone: json['timezone'] as String? ?? 'UTC',
      heightCm: json['height_cm'] != null
          ? (json['height_cm'] as num).toDouble()
          : null,
      heightUnit: json['height_unit'] as String? ?? 'cm',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert UserProfileModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'timezone': timezone,
      'height_cm': heightCm,
      'height_unit': heightUnit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? timezone,
    double? heightCm,
    String? heightUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timezone: timezone ?? this.timezone,
      heightCm: heightCm ?? this.heightCm,
      heightUnit: heightUnit ?? this.heightUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(id: $id, fullName: $fullName, avatarUrl: $avatarUrl, dateOfBirth: $dateOfBirth, timezone: $timezone, heightCm: $heightCm, heightUnit: $heightUnit, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfileModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.dateOfBirth == dateOfBirth &&
        other.timezone == timezone &&
        other.heightCm == heightCm &&
        other.heightUnit == heightUnit &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        avatarUrl.hashCode ^
        dateOfBirth.hashCode ^
        timezone.hashCode ^
        heightCm.hashCode ^
        heightUnit.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
