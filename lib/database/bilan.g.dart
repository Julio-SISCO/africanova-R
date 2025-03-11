// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bilan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BilanAdapter extends TypeAdapter<Bilan> {
  @override
  final int typeId = 22;

  @override
  Bilan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bilan(
      article: fields[0] as Article,
      mouvements: (fields[1] as List).cast<Mouvement>(),
      stockInitial: fields[2] as int,
      stockFinalEsperable: fields[3] as int,
      totalDebite: fields[4] as int,
      totalApprovision: fields[5] as int,
      detailsMouvements: fields[6] as DetailsMouvements,
    );
  }

  @override
  void write(BinaryWriter writer, Bilan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.article)
      ..writeByte(1)
      ..write(obj.mouvements)
      ..writeByte(2)
      ..write(obj.stockInitial)
      ..writeByte(3)
      ..write(obj.stockFinalEsperable)
      ..writeByte(4)
      ..write(obj.totalDebite)
      ..writeByte(5)
      ..write(obj.totalApprovision)
      ..writeByte(6)
      ..write(obj.detailsMouvements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BilanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MouvementAdapter extends TypeAdapter<Mouvement> {
  @override
  final int typeId = 24;

  @override
  Mouvement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mouvement(
      id: fields[0] as int,
      dateJour: fields[1] as DateTime,
      quantiteInitiale: fields[2] as int,
      quantiteMouvement: fields[3] as int,
      mouvement: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Mouvement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateJour)
      ..writeByte(2)
      ..write(obj.quantiteInitiale)
      ..writeByte(3)
      ..write(obj.quantiteMouvement)
      ..writeByte(4)
      ..write(obj.mouvement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MouvementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DetailsMouvementsAdapter extends TypeAdapter<DetailsMouvements> {
  @override
  final int typeId = 25;

  @override
  DetailsMouvements read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetailsMouvements(
      restitution: fields[0] as int,
      vente: fields[1] as int,
      annulationVente: fields[2] as int,
      service: fields[3] as int,
      annulationService: fields[4] as int,
      approvisionnement: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DetailsMouvements obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.restitution)
      ..writeByte(1)
      ..write(obj.vente)
      ..writeByte(2)
      ..write(obj.annulationVente)
      ..writeByte(3)
      ..write(obj.service)
      ..writeByte(4)
      ..write(obj.annulationService)
      ..writeByte(5)
      ..write(obj.approvisionnement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailsMouvementsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatistiqueAdapter extends TypeAdapter<Statistique> {
  @override
  final int typeId = 23;

  @override
  Statistique read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Statistique(
      salesToday: fields[0] as int,
      salesWeek: fields[1] as int,
      salesMonth: fields[2] as int,
      servicesToday: fields[3] as int,
      servicesWeek: fields[4] as int,
      servicesMonth: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Statistique obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.salesToday)
      ..writeByte(1)
      ..write(obj.salesWeek)
      ..writeByte(2)
      ..write(obj.salesMonth)
      ..writeByte(3)
      ..write(obj.servicesToday)
      ..writeByte(4)
      ..write(obj.servicesWeek)
      ..writeByte(5)
      ..write(obj.servicesMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatistiqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
