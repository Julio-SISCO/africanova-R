// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approvision.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApprovisionAdapter extends TypeAdapter<Approvision> {
  @override
  final int typeId = 21;

  @override
  Approvision read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Approvision(
      id: fields[0] as int?,
      montantTotal: fields[1] as double,
      employer: fields[2] as Employer?,
      fournisseur: fields[3] as Fournisseur?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      lignes: (fields[4] as List).cast<LigneApprovision>(),
    );
  }

  @override
  void write(BinaryWriter writer, Approvision obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.montantTotal)
      ..writeByte(2)
      ..write(obj.employer)
      ..writeByte(3)
      ..write(obj.fournisseur)
      ..writeByte(4)
      ..write(obj.lignes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
