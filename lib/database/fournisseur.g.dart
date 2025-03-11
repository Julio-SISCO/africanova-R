// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fournisseur.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FournisseurAdapter extends TypeAdapter<Fournisseur> {
  @override
  final int typeId = 7;

  @override
  Fournisseur read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fournisseur(
      id: fields[0] as int?,
      fullname: fields[1] as String?,
      email: fields[2] as String?,
      contact: fields[3] as String?,
      phone: fields[4] as String?,
      adresse: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Fournisseur obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullname)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.contact)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.adresse)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FournisseurAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
