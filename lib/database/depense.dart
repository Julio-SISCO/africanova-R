import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/database/employer.dart';
import 'package:hive/hive.dart';

part 'depense.g.dart';

@HiveType(typeId: 25)
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
  final Employer employer;

  @HiveField(6)
  final CategorieDepense categorieDepense;

  Depense({
    this.id,
    required this.montant,
    this.description,
    required this.date,
    required this.status,
    required this.employer,
    required this.categorieDepense,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      montant: (json['montant'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      employer: Employer.fromJson(json['employer']),
      categorieDepense: CategorieDepense.fromJson(json['categorie_depense']),
    );
  }

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
