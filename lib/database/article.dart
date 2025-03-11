import 'package:africanova/database/categorie.dart';
import 'package:africanova/database/image_article.dart';
import 'package:hive/hive.dart';

part 'article.g.dart';

@HiveType(typeId: 4)
class Article extends HiveObject {
  @HiveField(0)
  String? code;

  @HiveField(1)
  String? libelle;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int? stock;

  @HiveField(4)
  double? prixAchat;

  @HiveField(5)
  double? prixVente;

  @HiveField(6)
  Categorie? categorie;

  @HiveField(7)
  int? id;

  @HiveField(8)
  List<ImageArticle>? images;

  Article({
    this.id,
    this.libelle,
    this.code,
    this.description,
    this.stock,
    this.prixAchat,
    this.prixVente,
    this.categorie,
    this.images,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.parse(json['id'].toString()),
      code: json['code'],
      categorie: json['categorie'] != null
          ? Categorie.fromJson(json['categorie'])
          : null,
      libelle: json['libelle'],
      prixAchat: json['prix_achat'] != null
          ? double.tryParse(json['prix_achat'].toString())
          : 0.0,
      prixVente: json['prix_vente'] != null
          ? double.tryParse(json['prix_vente'].toString())
          : 0.0,
      stock: int.parse(json['quantite_stock'].toString()),
      description: json['description'],
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ImageArticle.fromJson(image))
          .toList(),
    );
  }
}
