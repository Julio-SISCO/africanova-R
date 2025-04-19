import 'package:africanova/database/employer.dart';
import 'package:hive/hive.dart';

part 'transfert.g.dart';

@HiveType(typeId: 31)
class Transfert extends HiveObject {
  @HiveField(0)
  String contact;

  @HiveField(1)
  double montant;

  @HiveField(2)
  double commission;

  @HiveField(3)
  String type;

  @HiveField(4)
  String reseau;

  @HiveField(5)
  String categorie;

  @HiveField(6)
  Employer? employer;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  String? description;

  @HiveField(9)
  String? reference;

  @HiveField(10)
  DateTime? createdAt;

  @HiveField(11)
  DateTime? updatedAt;

  @HiveField(12)
  int? id;

  Transfert({
    required this.contact,
    required this.montant,
    required this.commission,
    required this.type,
    required this.reseau,
    required this.categorie,
    this.employer,
    required this.date,
    this.description,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  factory Transfert.fromJson(Map<String, dynamic> json) {
    return Transfert(
      id: json['id'],
      contact: json['contact'],
      montant:  double.parse(json['montant'].toString()),
      commission:  double.parse(json['commission'].toString()),
      type: json['type'],
      reseau: json['reseau'],
      categorie: json['categorie'],
      employer:
          json['employer'] != null ? Employer.fromJson(json['employer']) : null,
      date: DateTime.parse(json['date']),
      description: json['description'],
      reference: json['reference'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'montant': montant,
      'commission': commission,
      'type': type,
      'reseau': reseau,
      'categorie': categorie,
      'date': date.toIso8601String(),
      'description': description,
      'reference': reference,
    };
  }
}
