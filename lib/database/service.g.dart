// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceAdapter extends TypeAdapter<Service> {
  @override
  final int typeId = 16;

  @override
  Service read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Service(
      id: fields[16] as int,
      description: fields[0] as String?,
      total: fields[1] as double?,
      remise: fields[2] as double?,
      remiseInPercent: fields[3] as bool,
      designationRemise: fields[4] as String?,
      taxe: fields[5] as double?,
      taxeInPercent: fields[6] as bool,
      designationTaxe: fields[7] as String?,
      client: fields[9] as Client,
      traiteur: fields[10] as Employer,
      typeServices: (fields[11] as List).cast<TypeService>(),
      articles: (fields[12] as List).cast<LigneArticle>(),
      outils: (fields[13] as List).cast<LigneOutil>(),
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      numFacture: fields[17] as String?,
      status: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Service obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.total)
      ..writeByte(2)
      ..write(obj.remise)
      ..writeByte(3)
      ..write(obj.remiseInPercent)
      ..writeByte(4)
      ..write(obj.designationRemise)
      ..writeByte(5)
      ..write(obj.taxe)
      ..writeByte(6)
      ..write(obj.taxeInPercent)
      ..writeByte(7)
      ..write(obj.designationTaxe)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.client)
      ..writeByte(10)
      ..write(obj.traiteur)
      ..writeByte(11)
      ..write(obj.typeServices)
      ..writeByte(12)
      ..write(obj.articles)
      ..writeByte(13)
      ..write(obj.outils)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.id)
      ..writeByte(17)
      ..write(obj.numFacture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
