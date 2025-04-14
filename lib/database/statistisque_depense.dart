import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/database/depense.dart';
import 'package:hive/hive.dart';

part 'statistisque_depense.g.dart';

@HiveType(typeId: 30)
class StatistisqueDepense {
  @HiveField(0)
  final CategorieDepense categorieDepense;

  @HiveField(1)
  final double totalMontant;

  @HiveField(2)
  final int totalQuantite;

  @HiveField(3)
  final List<Depense> depenses;

  StatistisqueDepense({
    required this.categorieDepense,
    required this.totalMontant,
    required this.totalQuantite,
    required this.depenses,
  });

  factory StatistisqueDepense.fromJson(Map<String, dynamic> json) {
    return StatistisqueDepense(
      categorieDepense: CategorieDepense.fromJson(json['categorie']),
      totalMontant: (json['montant_total'] as num).toDouble(),
      totalQuantite: json['quantite_total'] as int,
      depenses: (json['depenses'] as List<dynamic>)
          .map((e) => Depense.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categorie': categorieDepense.toJson(),
      'montant_total': totalMontant,
      'quantite_total': totalQuantite,
      'depenses': depenses.map((e) => e.toJson()).toList(),
    };
  }
}

class DepenseMensuelle {
  final String mois;
  final List<StatistisqueDepense> stats;

  DepenseMensuelle({required this.mois, required this.stats});
}
