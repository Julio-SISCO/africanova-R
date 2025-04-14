// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistisque_depense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatistisqueDepenseAdapter extends TypeAdapter<StatistisqueDepense> {
  @override
  final int typeId = 30;

  @override
  StatistisqueDepense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatistisqueDepense(
      categorieDepense: fields[0] as CategorieDepense,
      totalMontant: fields[1] as double,
      totalQuantite: fields[2] as int,
      depenses: (fields[3] as List).cast<Depense>(),
    );
  }

  @override
  void write(BinaryWriter writer, StatistisqueDepense obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.categorieDepense)
      ..writeByte(1)
      ..write(obj.totalMontant)
      ..writeByte(2)
      ..write(obj.totalQuantite)
      ..writeByte(3)
      ..write(obj.depenses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatistisqueDepenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
