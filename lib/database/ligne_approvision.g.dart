// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ligne_approvision.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LigneApprovisionAdapter extends TypeAdapter<LigneApprovision> {
  @override
  final int typeId = 20;

  @override
  LigneApprovision read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LigneApprovision(
      id: fields[0] as int?,
      quantite: fields[1] as int,
      prix: fields[2] as double?,
      article: fields[3] as Article,
    );
  }

  @override
  void write(BinaryWriter writer, LigneApprovision obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quantite)
      ..writeByte(2)
      ..write(obj.prix)
      ..writeByte(3)
      ..write(obj.article);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LigneApprovisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
