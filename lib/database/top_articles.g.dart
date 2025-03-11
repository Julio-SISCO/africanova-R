// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_articles.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TopArticlesAdapter extends TypeAdapter<TopArticles> {
  @override
  final int typeId = 18;

  @override
  TopArticles read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopArticles(
      article: fields[0] as Article,
      totalMontantVente: fields[1] as double,
      totalQuantiteVente: fields[2] as int,
      totalMontantService: fields[3] as double,
      totalQuantiteIntervention: fields[4] as int,
      score: fields[5] as double,
      pourcentageVente: fields[6] as double,
      pourcentageServices: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TopArticles obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.article)
      ..writeByte(1)
      ..write(obj.totalMontantVente)
      ..writeByte(2)
      ..write(obj.totalQuantiteVente)
      ..writeByte(3)
      ..write(obj.totalMontantService)
      ..writeByte(4)
      ..write(obj.totalQuantiteIntervention)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.pourcentageVente)
      ..writeByte(7)
      ..write(obj.pourcentageServices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopArticlesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TopVendeursAdapter extends TypeAdapter<TopVendeurs> {
  @override
  final int typeId = 19;

  @override
  TopVendeurs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopVendeurs(
      employer: fields[0] as Employer,
      totalMontantVente: fields[1] as double,
      totalMontantService: fields[2] as double,
      score: fields[3] as double,
      pourcentageVente: fields[4] as double,
      pourcentageServices: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TopVendeurs obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.employer)
      ..writeByte(1)
      ..write(obj.totalMontantVente)
      ..writeByte(2)
      ..write(obj.totalMontantService)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.pourcentageVente)
      ..writeByte(5)
      ..write(obj.pourcentageServices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopVendeursAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
