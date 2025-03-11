import 'package:hive/hive.dart';
import 'client.dart';
import 'type_service.dart';
import 'employer.dart';
import 'ligne_article.dart';
import 'ligne_outil.dart';

part 'service.g.dart';

@HiveType(typeId: 16)
class Service extends HiveObject {
  @HiveField(0)
  String? description;

  @HiveField(1)
  double? total;

  @HiveField(2)
  double? remise;

  @HiveField(3)
  bool remiseInPercent;

  @HiveField(4)
  String? designationRemise;

  @HiveField(5)
  double? taxe;

  @HiveField(6)
  bool taxeInPercent;

  @HiveField(7)
  String? designationTaxe;

  @HiveField(8)
  String? status;

  @HiveField(9)
  Client client;

  @HiveField(10)
  Employer traiteur;

  @HiveField(11)
  List<TypeService> typeServices;

  @HiveField(12)
  List<LigneArticle> articles;

  @HiveField(13)
  List<LigneOutil> outils;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  int id;

  @HiveField(17)
  String? numFacture;

  Service({
    required this.id,
    required this.description,
    required this.total,
    required this.remise,
    required this.remiseInPercent,
    required this.designationRemise,
    required this.taxe,
    required this.taxeInPercent,
    required this.designationTaxe,
    required this.client,
    required this.traiteur,
    required this.typeServices,
    required this.articles,
    required this.outils,
    required this.createdAt,
    required this.updatedAt,
    this.numFacture,
    this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: (json['id'] ?? 0) as int,
      description: json['description'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      remise: (json['remise'] as num?)?.toDouble(),
      remiseInPercent: json['remise_in_percent'] == 0
          ? false
          : json['remise_in_percent'] == 1
              ? true
              : json['remise_in_percent'] ?? false,
      designationRemise: json['designation_remise'] as String?,
      taxe: json['taxe'] != null ? double.parse(json['taxe'].toString()) : null,
      taxeInPercent: json['taxe_in_percent'] == 0
          ? false
          : json['taxe_in_percent'] == 1
              ? true
              : json['taxe_in_percent'] ?? false,
      designationTaxe: json['designation_taxe'] as String?,
      client: Client.fromJson(json['client']),
      traiteur: Employer.fromJson(json['traiteur']),
      typeServices: (json['ligne_services'] as List<dynamic>)
          .map((typeService) => TypeService.fromJson(typeService))
          .toList(),
      articles: (json['articles'] as List<dynamic>)
          .map((article) => LigneArticle.fromJson(article))
          .toList(),
      outils: (json['outils'] as List<dynamic>)
          .map((outil) => LigneOutil.fromJson(outil))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      numFacture: json['num_facture'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'total': total,
      'remise': remise,
      'remise_in_percent': remiseInPercent,
      'designation_remise': designationRemise,
      'taxe': taxe,
      'taxe_in_percent': taxeInPercent,
      'designation_taxe': designationTaxe,
      'client_id': client.id,
      'ligne_services':
          typeServices.map((typeService) => typeService.id).toList(),
      'articles': articles
          .map((article) => {
                'article_id': article.article.id,
                'montant': article.montant,
                'quantite': article.quantite,
              })
          .toList(),
      'outils': outils
          .map((outil) => {
                'outil_id': outil.outil.id,
                'montant': outil.montant,
                'quantite': outil.quantite,
              })
          .toList(),
      'status': status,
    };
  }
}
