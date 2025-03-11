import 'package:africanova/database/type_article.dart';
import 'package:africanova/database/type_outil.dart';
import 'package:hive/hive.dart';

part 'type_service.g.dart';

@HiveType(typeId: 15)
class TypeService extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String? code;

  @HiveField(2)
  String libelle;

  @HiveField(3)
  String? description;

  @HiveField(4)
  DateTime? createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  List<TypeOutil>? outilTypeList;

  @HiveField(7)
  List<TypeArticle>? articleTypeList;

  TypeService({
    required this.id,
    this.code,
    required this.libelle,
    this.outilTypeList,
    this.articleTypeList,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory TypeService.fromJson(Map<String, dynamic> json) {
    return TypeService(
      id: json['id'] as int,
      code: json['code'] as String?,
      libelle: json['libelle'] as String,
      description: json['description'] as String?,
      outilTypeList: json['outils'] == null
          ? null
          : (json['outils'] as List<dynamic>?)!
              .map((ot) => TypeOutil.fromJson(ot))
              .toList(),
      articleTypeList: json['articles'] == null
          ? null
          : (json['articles'] as List<dynamic>?)!
              .map((ot) => TypeArticle.fromJson(ot))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'description': description,
      'outils': outilTypeList?.map((outil) => outil.toJson()).toList() ?? [],
      'articles':
          articleTypeList?.map((article) => article.toJson()).toList() ?? [],
    };
  }
}
