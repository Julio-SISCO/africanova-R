import 'package:africanova/database/article.dart';
import 'package:hive/hive.dart';

part 'ligne_article.g.dart';

@HiveType(typeId: 9)
class LigneArticle extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int quantite;

  @HiveField(2)
  double? montant;

  @HiveField(3)
  Article article;

  @HiveField(4)
  String? designation;

  @HiveField(5)
  bool? applyTarif;

  @HiveField(6)
  int? parentId;

  LigneArticle({
    this.id,
    this.quantite = 1,
    this.montant,
    required this.article,
    this.designation,
    this.applyTarif,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantite': quantite,
      'article_id': article.id,
      'montant': montant,
    };
  }

  factory LigneArticle.fromJson(Map<String, dynamic> json) {
    return LigneArticle(
      id: json['id'],
      quantite: json['quantite'],
      montant: json['montant'] != null
          ? double.parse(json['montant'].toString())
          : 0.0,
      article: Article.fromJson(json['article']),
    );
  }
}
