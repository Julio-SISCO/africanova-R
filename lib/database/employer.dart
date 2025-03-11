import 'package:hive/hive.dart';

part 'employer.g.dart';

@HiveType(typeId: 6)
class Employer extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String prenom;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? contact;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  String? adresse;

  @HiveField(7)
  DateTime? createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  Employer({
    this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.contact,
    this.phone,
    this.adresse,
    this.createdAt,
    this.updatedAt,
  });

  factory Employer.fromJson(Map<String, dynamic> json) {
    return Employer(
      id: int.parse(json['id'].toString()),
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      adresse: json['adresse'],
      contact: json['contact'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
