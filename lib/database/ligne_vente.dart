import 'package:africanova/database/article.dart';
import 'package:hive/hive.dart';

part 'ligne_vente.g.dart';

@HiveType(typeId: 11)
class LigneVente extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int quantite;

  @HiveField(2)
  double? montant;

  @HiveField(3)
  Article article;

  @HiveField(4)
  DateTime? createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  LigneVente({
    this.id,
    this.quantite = 1,
    this.montant,
    this.createdAt,
    this.updatedAt,
    required this.article,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantite': quantite,
      'article': article.id,
    };
  }

  factory LigneVente.fromJson(Map<String, dynamic> json) {
    return LigneVente(
      id: json['id'],
      quantite: json['quantite'],
      montant: json['montant'] != null
          ? double.parse(json['montant'].toString())
          : 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      article: Article.fromJson(json['article']),
    );
  }
}
