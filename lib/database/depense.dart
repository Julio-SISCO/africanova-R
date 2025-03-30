import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/database/document.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/image_article.dart';
import 'package:hive/hive.dart';

part 'depense.g.dart';

@HiveType(typeId: 29)
class Depense extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final double montant;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final Employer? employer;

  @HiveField(6)
  final CategorieDepense categorieDepense;

  @HiveField(7)
  List<Document> documents;

  @HiveField(8)
  List<ImageArticle> images;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  Depense({
    this.id,
    required this.montant,
    this.description,
    required this.date,
    required this.status,
    required this.employer,
    required this.categorieDepense,
    this.documents = const [],
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit un JSON en objet `Depense`
  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      montant: (json['montant'] != null)
          ? double.tryParse(json['montant'].toString()) ?? 0.0
          : 0.0,
      description: json['description'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      employer:
          json['employer'] != null ? Employer.fromJson(json['employer']) : null,
      categorieDepense: CategorieDepense.fromJson(json['categorie_depense']),
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) => Document.fromJson(doc))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ImageArticle.fromJson(img))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convertit un objet `Depense` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'categorie_depense': categorieDepense.toJson(),
    };
  }
}
