// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeServiceAdapter extends TypeAdapter<TypeService> {
  @override
  final int typeId = 15;

  @override
  TypeService read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeService(
      id: fields[0] as int,
      code: fields[1] as String?,
      libelle: fields[2] as String,
      outilTypeList: (fields[6] as List?)?.cast<TypeOutil>(),
      articleTypeList: (fields[7] as List?)?.cast<TypeArticle>(),
      description: fields[3] as String?,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TypeService obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.libelle)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.outilTypeList)
      ..writeByte(7)
      ..write(obj.articleTypeList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeServiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
