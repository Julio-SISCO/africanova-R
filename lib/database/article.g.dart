// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 4;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      id: fields[7] as int?,
      libelle: fields[1] as String?,
      code: fields[0] as String?,
      description: fields[2] as String?,
      stock: fields[3] as int?,
      prixAchat: fields[4] as double?,
      prixVente: fields[5] as double?,
      categorie: fields[6] as Categorie?,
      images: (fields[8] as List?)?.cast<ImageArticle>(),
    );
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.libelle)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.stock)
      ..writeByte(4)
      ..write(obj.prixAchat)
      ..writeByte(5)
      ..write(obj.prixVente)
      ..writeByte(6)
      ..write(obj.categorie)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(8)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
