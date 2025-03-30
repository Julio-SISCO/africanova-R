// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'depense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DepenseAdapter extends TypeAdapter<Depense> {
  @override
  final int typeId = 29;

  @override
  Depense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Depense(
      id: fields[0] as int?,
      montant: fields[1] as double,
      description: fields[2] as String?,
      date: fields[3] as DateTime,
      status: fields[4] as String,
      employer: fields[5] as Employer?,
      categorieDepense: fields[6] as CategorieDepense,
      documents: (fields[7] as List).cast<Document>(),
      images: (fields[8] as List).cast<ImageArticle>(),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Depense obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.montant)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.employer)
      ..writeByte(6)
      ..write(obj.categorieDepense)
      ..writeByte(7)
      ..write(obj.documents)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
