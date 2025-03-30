import 'package:hive/hive.dart';

part 'type_depense.g.dart';

@HiveType(typeId: 26)
class TypeDepense {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int categories;

  TypeDepense({
    this.id,
    required this.nom,
    this.description,
    required this.categories,
  });

  factory TypeDepense.fromJson(Map<String, dynamic> json) {
    return TypeDepense(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      categories: json['categories_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': nom,
      'description': description,
    };
  }
}
