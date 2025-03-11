import 'package:africanova/database/article.dart';
import 'package:africanova/database/type_service.dart';
import 'package:hive/hive.dart';

part 'type_article.g.dart';

@HiveType(typeId: 17)
class TypeArticle extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  Article article;

  @HiveField(2)
  TypeService? typeService;

  @HiveField(3)
  double? tarifUsager;

  TypeArticle({
    required this.id,
    required this.article,
    this.typeService,
    this.tarifUsager,
  });

  factory TypeArticle.fromJson(Map<String, dynamic> json) {
    return TypeArticle(
      id: json['id'] as int,
      article: Article.fromJson(json['article']),
      typeService: json['type_service'] == null
          ? null
          : TypeService.fromJson(json['type_service']),
      tarifUsager: (json['tarif_a_l_unite'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article_id': article.id,
      'tarif_a_l_unite': tarifUsager,
    };
  }
}
