import 'package:africanova/database/client.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/ligne_vente.dart';
import 'package:hive/hive.dart';

part 'vente.g.dart';

@HiveType(typeId: 14)
class Vente extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  double montantTotal;

  @HiveField(2)
  Employer? employer;

  @HiveField(3)
  Client? client;

  @HiveField(4)
  Employer? initiateur;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  @HiveField(7)
  List<LigneVente> lignes;

  @HiveField(10)
  String? status;

  @HiveField(11)
  double? taxe;

  @HiveField(12)
  String? designationTaxe;

  @HiveField(13)
  bool? taxeInPercent;

  @HiveField(14)
  double? remise;

  @HiveField(8)
  String? designationRemise;

  @HiveField(9)
  bool? remiseInPercent;

  @HiveField(15)
  String? numFacture;

  Vente({
    this.id,
    required this.montantTotal,
    this.employer,
    this.client,
    this.createdAt,
    this.updatedAt,
    this.initiateur,
    this.status,
    required this.lignes,
    this.taxe,
    this.designationTaxe,
    this.taxeInPercent,
    this.remise,
    this.designationRemise,
    this.remiseInPercent,
    this.numFacture,
  });

  // Méthode pour calculer le total TTC
  double calculateTotal() {
    double totalLignes = lignes.fold(0,
        (sum, ligne) => sum + (ligne.article?.prixVente ?? 0) * ligne.quantite);
    double taxeAmount = 0.0;
    double remiseAmount = 0.0;

    if (taxe != null && taxe! > 0) {
      taxeAmount =
          (taxeInPercent == true) ? (totalLignes * taxe! / 100) : taxe!;
    }
    if (remise != null && remise! > 0) {
      remiseAmount =
          (remiseInPercent == true) ? (totalLignes * remise! / 100) : remise!;
    }

    double totalTTC = totalLignes + taxeAmount - remiseAmount;
    return totalTTC >= 0 ? totalTTC : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'lignes': lignes.map((ligne) => ligne.toJson()).toList(),
      'client': client?.id ?? 0,
      'taxe': taxe,
      'designation_taxe': designationTaxe,
      'taxe_in_percent': taxeInPercent,
      'remise': remise,
      'designation_remise': designationRemise,
      'remise_in_percent': remiseInPercent,
      'status': status,
    };
  }

  // Méthode fromJson
  factory Vente.fromJson(Map<String, dynamic> json) {
    return Vente(
      id: json['id'],
      montantTotal: double.parse(json['montant_total'].toString()),
      employer:
          json['employer'] != null ? Employer.fromJson(json['employer']) : null,
      initiateur: json['initiateur'] != null
          ? Employer.fromJson(json['initiateur'])
          : null,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      lignes: (json['lignes'] as List)
          .map((ligne) => LigneVente.fromJson(ligne))
          .toList(),
      taxe: json['taxe'] != null ? double.parse(json['taxe'].toString()) : null,
      designationTaxe: json['designation_taxe'],
      taxeInPercent: json['taxe_in_percent'] == 1
          ? true
          : json['taxe_in_percent'] == 0
              ? false
              : json['taxe_in_percent'],
      remise: json['remise'] != null
          ? double.parse(json['remise'].toString())
          : null,
      designationRemise: json['designation_remise'],
      remiseInPercent: json['remise_in_percent'] == 1
          ? true
          : json['remise_in_percent'] == 0
              ? false
              : json['remise_in_percent'],
      numFacture: json['num_facture'],
    );
  }
}
