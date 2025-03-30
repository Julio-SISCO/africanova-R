import 'package:hive/hive.dart';

part 'my_icon.g.dart';

@HiveType(typeId: 27)
class MyIcon extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String libelle;

  @HiveField(2)
  String nom;

  MyIcon({required this.id, required this.libelle, required this.nom});

  factory MyIcon.fromJson(Map<String, dynamic> json) {
    return MyIcon(
      id: json['id'],
      libelle: json['libelle'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
