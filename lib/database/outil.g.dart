// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outil.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutilAdapter extends TypeAdapter<Outil> {
  @override
  final int typeId = 13;

  @override
  Outil read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Outil(
      id: fields[0] as int,
      libelle: fields[1] as String,
      description: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Outil obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.libelle)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutilAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
