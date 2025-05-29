import 'package:africanova/database/outil.dart';
import 'package:hive/hive.dart';

part 'ligne_outil.g.dart';

@HiveType(typeId: 10)
class LigneOutil extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int quantite;

  @HiveField(2)
  double? montant;

  @HiveField(3)
  Outil outil;

  @HiveField(4)
  String? designation;

  @HiveField(5)
  bool? applyTarif;

  @HiveField(6)
  int? parentId;

  LigneOutil({
    this.id,
    this.quantite = 1,
    this.montant,
    required this.outil,
    this.designation,
    this.applyTarif,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantite': quantite,
      'outil_id': outil.id,
      'montant': montant,
    };
  }

  factory LigneOutil.fromJson(Map<String, dynamic> json) {
    return LigneOutil(
      id: json['id'],
      quantite: json['quantite'],
      montant: json['montant'] != null
          ? double.parse(json['montant'].toString())
          : 0.0,
      outil: Outil.fromJson(json['outil']),
    );
  }
}
