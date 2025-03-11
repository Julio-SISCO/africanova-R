// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployerAdapter extends TypeAdapter<Employer> {
  @override
  final int typeId = 6;

  @override
  Employer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employer(
      id: fields[0] as int?,
      nom: fields[1] as String,
      prenom: fields[2] as String,
      email: fields[3] as String?,
      contact: fields[4] as String?,
      phone: fields[5] as String?,
      adresse: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Employer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.prenom)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.contact)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.adresse)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
