import 'package:hive/hive.dart';

part 'fournisseur.g.dart';

@HiveType(typeId: 7)
class Fournisseur extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? fullname;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? contact;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? adresse;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  Fournisseur({
    this.id,
    this.fullname,
    this.email,
    this.contact,
    this.phone,
    this.adresse,
    this.createdAt,
    this.updatedAt,
  });

  // Méthode pour convertir un JSON en Categorie
  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: int.parse(json['id'].toString()),
      fullname: json['fullname'],
      email: json['email'],
      adresse: json['adresse'],
      contact: json['contact'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
