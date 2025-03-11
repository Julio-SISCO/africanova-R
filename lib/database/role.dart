import 'package:africanova/database/user.dart';
import 'package:hive/hive.dart';
import 'permission.dart';

part 'role.g.dart';

@HiveType(typeId: 1)
class Role {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Permission> permissions;
  @HiveField(3)
  final List<User> users;

  Role({
    this.id,
    required this.name,
    required this.permissions,
    required this.users,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      permissions: (json['permissions'] as List)
          .map((permission) => Permission.fromJson(permission))
          .toList(),
      users: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}
