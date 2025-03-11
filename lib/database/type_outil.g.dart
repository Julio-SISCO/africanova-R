// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_outil.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeOutilAdapter extends TypeAdapter<TypeOutil> {
  @override
  final int typeId = 12;

  @override
  TypeOutil read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeOutil(
      id: fields[0] as int,
      outil: fields[1] as Outil,
      typeService: fields[2] as TypeService?,
      tarifUsager: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TypeOutil obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.outil)
      ..writeByte(2)
      ..write(obj.typeService)
      ..writeByte(3)
      ..write(obj.tarifUsager);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeOutilAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
