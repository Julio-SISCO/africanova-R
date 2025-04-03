import 'package:hive/hive.dart';

part 'categorie.g.dart';

@HiveType(typeId: 3)
class Categorie extends HiveObject {
  @HiveField(0)
  String? code;

  @HiveField(1)
  String? libelle;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int? id;

  @HiveField(4)
  int? nbArticle;

  Categorie({
    this.code,
    this.libelle,
    this.description,
    this.id,
    this.nbArticle = 0,
  });

  // Méthode pour convertir un JSON en Categorie
  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: int.parse(json['id'].toString()),
      code: json['code'],
      libelle: json['libelle'],
      description: json['description'],
      nbArticle: json['articles_count'],
    );
  }

  // Méthode pour convertir Categorie en JSON (si besoin)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'libelle': libelle,
      'description': description,
    };
  }
}
