// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfert.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransfertAdapter extends TypeAdapter<Transfert> {
  @override
  final int typeId = 31;

  @override
  Transfert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transfert(
      contact: fields[0] as String,
      montant: fields[1] as double,
      commission: fields[2] as double,
      type: fields[3] as String,
      reseau: fields[4] as String,
      categorie: fields[5] as String,
      employer: fields[6] as Employer?,
      date: fields[7] as DateTime,
      description: fields[8] as String?,
      reference: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Transfert obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.contact)
      ..writeByte(1)
      ..write(obj.montant)
      ..writeByte(2)
      ..write(obj.commission)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.reseau)
      ..writeByte(5)
      ..write(obj.categorie)
      ..writeByte(6)
      ..write(obj.employer)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.reference)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransfertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
