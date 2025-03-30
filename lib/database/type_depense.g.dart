// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_depense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeDepenseAdapter extends TypeAdapter<TypeDepense> {
  @override
  final int typeId = 26;

  @override
  TypeDepense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeDepense(
      id: fields[0] as int?,
      nom: fields[1] as String,
      description: fields[2] as String?,
      categories: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TypeDepense obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.categories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeDepenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
