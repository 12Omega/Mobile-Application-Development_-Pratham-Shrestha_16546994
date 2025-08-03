import '../../domain/entities/user_profile.dart';

class UserProfileDto {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String createdAt;
  final String updatedAt;

  UserProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }

  factory UserProfileDto.fromEntity(UserProfile entity) {
    return UserProfileDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}