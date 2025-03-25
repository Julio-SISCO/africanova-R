import 'package:hive/hive.dart';

part 'type_depense.g.dart';

@HiveType(typeId: 23)
class TypeDepense {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String? description;

  TypeDepense({
    this.id,
    required this.nom,
    this.description,
  });

  factory TypeDepense.fromJson(Map<String, dynamic> json) {
    return TypeDepense(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
    };
  }
}
