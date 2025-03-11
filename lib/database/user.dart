import 'package:africanova/database/employer.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  Employer? employer;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final DateTime? createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  @HiveField(6)
  final DateTime? lastLogin;

  @HiveField(7)
  final List<Role>? roles;

  @HiveField(8)
  final List<Permission>? permissions;

  User({
    this.id,
    required this.username,
    this.employer,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.roles = const [],
    this.permissions = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      employer:
          json['profile'] != null ? Employer.fromJson(json['profile']) : null,
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLogin: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at']),
      permissions: json['permissions'] == null
          ? null
          : (json['permissions'] as List)
              .map((permission) => Permission.fromJson(permission))
              .toList(),
      roles: json['roles'] == null
          ? null
          : (json['roles'] as List).map((role) => Role.fromJson(role)).toList(),
    );
  }
}
