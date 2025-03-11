// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategorieAdapter extends TypeAdapter<Categorie> {
  @override
  final int typeId = 3;

  @override
  Categorie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Categorie(
      code: fields[0] as String?,
      libelle: fields[1] as String?,
      description: fields[2] as String?,
      id: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Categorie obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.libelle)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
