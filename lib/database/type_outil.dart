import 'package:africanova/database/outil.dart';
import 'package:africanova/database/type_service.dart';
import 'package:hive/hive.dart';

part 'type_outil.g.dart';

@HiveType(typeId: 12)
class TypeOutil extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  Outil outil;

  @HiveField(2)
  TypeService? typeService;

  @HiveField(3)
  double? tarifUsager;

  TypeOutil({
    required this.id,
    required this.outil,
    this.typeService,
    this.tarifUsager,
  });

  factory TypeOutil.fromJson(Map<String, dynamic> json) {
    return TypeOutil(
      id: json['id'] as int,
      outil: Outil.fromJson(json['outil']),
      typeService: json['type_service'] == null
          ? null
          : TypeService.fromJson(json['type_service']),
      tarifUsager: (json['tarif_a_l_unite'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outil_id': outil.id,
      'tarif_a_l_unite': tarifUsager,
    };
  }
}
