import 'package:hive/hive.dart';

part 'document.g.dart';

@HiveType(typeId: 30)
class Document extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final String chemin;

  @HiveField(3)
  final String type;

  Document({
    this.id,
    required this.nom,
    required this.chemin,
    required this.type,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      nom: json['nom'],
      chemin: json['chemin'],
      type: json['type'],
    );
  }

  /// Convertit un objet `Document` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'chemin': chemin,
      'type': type,
    };
  }
}
