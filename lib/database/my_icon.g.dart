// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_icon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyIconAdapter extends TypeAdapter<MyIcon> {
  @override
  final int typeId = 27;

  @override
  MyIcon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyIcon(
      id: fields[0] as int,
      libelle: fields[1] as String,
      nom: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MyIcon obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.libelle)
      ..writeByte(2)
      ..write(obj.nom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyIconAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
