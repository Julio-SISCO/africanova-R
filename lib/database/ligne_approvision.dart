import 'package:africanova/database/article.dart';
import 'package:hive/hive.dart';

part 'ligne_approvision.g.dart';

@HiveType(typeId: 20)
class LigneApprovision extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int quantite;

  @HiveField(2)
  double? prix;

  @HiveField(3)
  Article article;

  LigneApprovision({
    this.id,
    this.quantite = 1,
    this.prix,
    required this.article,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantite': quantite,
      'article': article.id,
      'prix': prix,
    };
  }

  factory LigneApprovision.fromJson(Map<String, dynamic> json) {
    return LigneApprovision(
      id: json['id'],
      quantite: json['quantite'],
      prix: json['prix'] != null ? double.parse(json['prix'].toString()) : 0.0,
      article: Article.fromJson(json['related']),
    );
  }
}
