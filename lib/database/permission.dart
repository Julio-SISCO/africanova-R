import 'package:hive/hive.dart';

part 'permission.g.dart';

@HiveType(typeId: 0)
class Permission {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;

  Permission({
    this.id = 0,
    required this.name,
    required this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      description: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
