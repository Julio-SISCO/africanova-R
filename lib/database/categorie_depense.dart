import 'package:africanova/database/my_icon.dart';
import 'package:africanova/database/type_depense.dart';
import 'package:hive/hive.dart';

part 'categorie_depense.g.dart';

@HiveType(typeId: 28)
class CategorieDepense extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String? description;

  @HiveField(3)
  TypeDepense? typeDepense;

  @HiveField(4)
  MyIcon? icon;

  CategorieDepense({
    this.id,
    required this.nom,
    this.description,
    required this.typeDepense,
    this.icon,
  });

  factory CategorieDepense.fromJson(Map<String, dynamic> json) {
    return CategorieDepense(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      typeDepense: json['type_depense'] == null ? null :  TypeDepense.fromJson(json['type_depense']),
      icon: json['icon'] == null ? null : MyIcon.fromJson(json['icon']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': nom,
      'description': description,
      'type': typeDepense?.id,
      'icon': icon?.id,
    };
  }
}
