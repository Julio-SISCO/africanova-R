// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ligne_outil.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LigneOutilAdapter extends TypeAdapter<LigneOutil> {
  @override
  final int typeId = 10;

  @override
  LigneOutil read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LigneOutil(
      id: fields[0] as int?,
      quantite: fields[1] as int,
      montant: fields[2] as double?,
      outil: fields[3] as Outil,
      designation: fields[4] as String?,
      applyTarif: fields[5] as bool?,
      parentId: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LigneOutil obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quantite)
      ..writeByte(2)
      ..write(obj.montant)
      ..writeByte(3)
      ..write(obj.outil)
      ..writeByte(4)
      ..write(obj.designation)
      ..writeByte(5)
      ..write(obj.applyTarif)
      ..writeByte(6)
      ..write(obj.parentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LigneOutilAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
