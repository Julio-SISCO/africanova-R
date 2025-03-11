import 'package:africanova/database/article.dart';
import 'package:hive/hive.dart';

part 'bilan.g.dart';

@HiveType(typeId: 22)
class Bilan extends HiveObject {
  @HiveField(0)
  final Article article;

  @HiveField(1)
  final List<Mouvement> mouvements;

  @HiveField(2)
  final int stockInitial;

  @HiveField(3)
  final int stockFinalEsperable;

  @HiveField(4)
  final int totalDebite;

  @HiveField(5)
  final int totalApprovision;

  @HiveField(6)
  final DetailsMouvements detailsMouvements;

  Bilan({
    required this.article,
    required this.mouvements,
    required this.stockInitial,
    required this.stockFinalEsperable,
    required this.totalDebite,
    required this.totalApprovision,
    required this.detailsMouvements,
  });

  factory Bilan.fromJson(Map<String, dynamic> json) {
    return Bilan(
      article: Article.fromJson(json['article']),
      mouvements: (json['mouvements'] as List<dynamic>)
          .map((e) => Mouvement.fromJson(e))
          .toList(),
      stockInitial: json['stock_initial'],
      stockFinalEsperable: json['stock_final_esperable'],
      totalDebite: json['total_debite'],
      totalApprovision: json['total_approvision'],
      detailsMouvements: DetailsMouvements.fromJson(json['details_mouvements']),
    );
  }
}

@HiveType(typeId: 24)
class Mouvement extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime dateJour;

  @HiveField(2)
  final int quantiteInitiale;

  @HiveField(3)
  final int quantiteMouvement;

  @HiveField(4)
  final String mouvement;

  Mouvement({
    required this.id,
    required this.dateJour,
    required this.quantiteInitiale,
    required this.quantiteMouvement,
    required this.mouvement,
  });

  factory Mouvement.fromJson(Map<String, dynamic> json) {
    return Mouvement(
      id: json['id'],
      dateJour: DateTime.parse(json['date_jour']),
      quantiteInitiale: json['quantite_initiale'],
      quantiteMouvement: json['quantite_mouvement'],
      mouvement: json['mouvement'],
    );
  }
}

@HiveType(typeId: 25)
class DetailsMouvements extends HiveObject {
  @HiveField(0)
  final int restitution;

  @HiveField(1)
  final int vente;

  @HiveField(2)
  final int annulationVente;

  @HiveField(3)
  final int service;

  @HiveField(4)
  final int annulationService;

  @HiveField(5)
  final int approvisionnement;

  DetailsMouvements({
    required this.restitution,
    required this.vente,
    required this.annulationVente,
    required this.service,
    required this.annulationService,
    required this.approvisionnement,
  });

  factory DetailsMouvements.fromJson(Map<String, dynamic> json) {
    return DetailsMouvements(
      restitution: json['restitution'],
      vente: json['vente'],
      annulationVente: json['annulation_vente'],
      service: json['service'],
      annulationService: json['annulation_service'],
      approvisionnement: json['approvisionnement'],
    );
  }
}

@HiveType(typeId: 23)
class Statistique extends HiveObject {
  @HiveField(0)
  final int salesToday;

  @HiveField(1)
  final int salesWeek;

  @HiveField(2)
  final int salesMonth;

  @HiveField(3)
  final int servicesToday;

  @HiveField(4)
  final int servicesWeek;

  @HiveField(5)
  final int servicesMonth;

  Statistique({
    required this.salesToday,
    required this.salesWeek,
    required this.salesMonth,
    required this.servicesToday,
    required this.servicesWeek,
    required this.servicesMonth,
  });

  factory Statistique.fromJson(Map<String, dynamic> json) {
    return Statistique(
      salesToday: json["sales_today"] ?? 0,
      salesWeek: json["sales_week"] ?? 0,
      salesMonth: json["sales_month"] ?? 0,
      servicesToday: json["services_today"] ?? 0,
      servicesWeek: json["services_week"] ?? 0,
      servicesMonth: json["services_month"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sales_today": salesToday,
      "sales_week": salesWeek,
      "sales_month": salesMonth,
      "services_today": servicesToday,
      "services_week": servicesWeek,
      "services_month": servicesMonth,
    };
  }
}
