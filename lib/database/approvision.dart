import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/ligne_approvision.dart';
import 'package:hive/hive.dart';

part 'approvision.g.dart';

@HiveType(typeId: 21)
class Approvision extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  double montantTotal;

  @HiveField(2)
  Employer? employer;

  @HiveField(3)
  Fournisseur? fournisseur;

  @HiveField(4)
  List<LigneApprovision> lignes;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  Approvision({
    this.id,
    required this.montantTotal,
    this.employer,
    this.fournisseur,
    this.createdAt,
    this.updatedAt,
    required this.lignes,
  });

  double calculateTotal() {
    double totalLignes = lignes.fold(0,
        (sum, ligne) => sum + (ligne.article.prixAchat ?? 0) * ligne.quantite);

    double totalTTC = totalLignes;
    return totalTTC >= 0 ? totalTTC : 0.0;
  }

  // Méthode toJson
  Map<String, dynamic> toJson() {
    return {
      'fournisseur': fournisseur?.id ?? 0,
      'lignes': lignes.map((ligne) => ligne.toJson()).toList(),
    };
  }

  // Méthode fromJson
  factory Approvision.fromJson(Map<String, dynamic> json) {
    return Approvision(
      id: json['id'],
      montantTotal: double.parse(json['montant_total'].toString()),
      employer:
          json['employer'] != null ? Employer.fromJson(json['employer']) : null,
      fournisseur: json['fournisseur'] != null
          ? Fournisseur.fromJson(json['fournisseur'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      lignes: (json['lignes'] as List)
          .map((ligne) => LigneApprovision.fromJson(ligne))
          .toList(),
    );
  }
}
