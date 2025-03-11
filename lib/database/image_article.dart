import 'package:hive/hive.dart';

part 'image_article.g.dart';

@HiveType(typeId: 8)
class ImageArticle {
  @HiveField(0)
  int id;

  @HiveField(1)
  String path;

  ImageArticle({
    required this.id,
    required this.path,
  });

  factory ImageArticle.fromJson(json) {
    return ImageArticle(
      id: json['id'],
      path: json['path'],
    );
  }
}
