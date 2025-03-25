import 'package:africanova/database/type_depense.dart';
import 'package:hive/hive.dart';

part 'categorie_depense.g.dart';

@HiveType(typeId: 24)
class CategorieDepense extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final TypeDepense typeDepense;

  CategorieDepense({
    this.id,
    required this.nom,
    this.description,
    required this.typeDepense,
  });

  factory CategorieDepense.fromJson(Map<String, dynamic> json) {
    return CategorieDepense(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      typeDepense: TypeDepense.fromJson(json['type_depense']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type_depense': typeDepense.id,
    };
  }
}
