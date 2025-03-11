import 'package:hive/hive.dart';

part 'outil.g.dart';

@HiveType(typeId: 13)
class Outil extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String libelle;

  @HiveField(2)
  String? description;

  Outil({
    required this.id,
    required this.libelle,
    this.description,
  });

  factory Outil.fromJson(Map<String, dynamic> json) {
    return Outil(
      id: json['id'] as int,
      libelle: json['libelle'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'description': description,
    };
  }
}
