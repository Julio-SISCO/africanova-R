// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ligne_vente.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LigneVenteAdapter extends TypeAdapter<LigneVente> {
  @override
  final int typeId = 11;

  @override
  LigneVente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LigneVente(
      id: fields[0] as int?,
      quantite: fields[1] as int,
      montant: fields[2] as double?,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
      article: fields[3] as Article,
    );
  }

  @override
  void write(BinaryWriter writer, LigneVente obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quantite)
      ..writeByte(2)
      ..write(obj.montant)
      ..writeByte(3)
      ..write(obj.article)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LigneVenteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
