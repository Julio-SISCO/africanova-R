// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VenteAdapter extends TypeAdapter<Vente> {
  @override
  final int typeId = 14;

  @override
  Vente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vente(
      id: fields[0] as int?,
      montantTotal: fields[1] as double,
      employer: fields[2] as Employer?,
      client: fields[3] as Client?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      initiateur: fields[4] as Employer?,
      status: fields[10] as String?,
      lignes: (fields[7] as List).cast<LigneVente>(),
      taxe: fields[11] as double?,
      designationTaxe: fields[12] as String?,
      taxeInPercent: fields[13] as bool?,
      remise: fields[14] as double?,
      designationRemise: fields[8] as String?,
      remiseInPercent: fields[9] as bool?,
      numFacture: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Vente obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.montantTotal)
      ..writeByte(2)
      ..write(obj.employer)
      ..writeByte(3)
      ..write(obj.client)
      ..writeByte(4)
      ..write(obj.initiateur)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.lignes)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.taxe)
      ..writeByte(12)
      ..write(obj.designationTaxe)
      ..writeByte(13)
      ..write(obj.taxeInPercent)
      ..writeByte(14)
      ..write(obj.remise)
      ..writeByte(8)
      ..write(obj.designationRemise)
      ..writeByte(9)
      ..write(obj.remiseInPercent)
      ..writeByte(15)
      ..write(obj.numFacture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VenteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
