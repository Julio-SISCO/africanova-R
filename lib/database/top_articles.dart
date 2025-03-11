import 'package:africanova/database/article.dart';
import 'package:africanova/database/employer.dart';
import 'package:hive/hive.dart';

part 'top_articles.g.dart';

@HiveType(typeId: 18)
class TopArticles {
  @HiveField(0)
  final Article article;
  @HiveField(1)
  final double totalMontantVente;
  @HiveField(2)
  final int totalQuantiteVente;
  @HiveField(3)
  final double totalMontantService;
  @HiveField(4)
  final int totalQuantiteIntervention;
  @HiveField(5)
  final double score;
  @HiveField(6)
  final double pourcentageVente;
  @HiveField(7)
  final double pourcentageServices;

  TopArticles({
    required this.article,
    required this.totalMontantVente,
    required this.totalQuantiteVente,
    required this.totalMontantService,
    required this.totalQuantiteIntervention,
    required this.score,
    required this.pourcentageVente,
    required this.pourcentageServices,
  });

  factory TopArticles.fromJson(Map<String, dynamic> json) {
    return TopArticles(
      article: Article.fromJson(json['article']),
      totalMontantVente: (json['montant_total_ventes'] as num).toDouble(),
      totalQuantiteVente: json['quantite_total_ventes'] as int,
      totalMontantService: (json['montant_total_services'] as num).toDouble(),
      totalQuantiteIntervention: json['quantite_total_services'] as int,
      score: (json['score'] as num).toDouble(),
      pourcentageVente: (json['pourcentage_ventes'] as num).toDouble(),
      pourcentageServices: (json['pourcentage_services'] as num).toDouble(),
    );
  }
}

@HiveType(typeId: 19)
class TopVendeurs {
  @HiveField(0)
  final Employer employer;
  @HiveField(1)
  final double totalMontantVente;
  @HiveField(2)
  final double totalMontantService;
  @HiveField(3)
  final double score;
  @HiveField(4)
  final double pourcentageVente;
  @HiveField(5)
  final double pourcentageServices;

  TopVendeurs({
    required this.employer,
    required this.totalMontantVente,
    required this.totalMontantService,
    required this.score,
    required this.pourcentageVente,
    required this.pourcentageServices,
  });

  factory TopVendeurs.fromJson(Map<String, dynamic> json) {
    return TopVendeurs(
      employer: Employer.fromJson(json['employer']),
      totalMontantVente: (json['montant_total_ventes'] as num).toDouble(),
      totalMontantService: (json['montant_total_services'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      pourcentageVente: (json['pourcentage_ventes'] as num).toDouble(),
      pourcentageServices: (json['pourcentage_services'] as num).toDouble(),
    );
  }
}
