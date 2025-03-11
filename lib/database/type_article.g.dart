// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeArticleAdapter extends TypeAdapter<TypeArticle> {
  @override
  final int typeId = 17;

  @override
  TypeArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeArticle(
      id: fields[0] as int,
      article: fields[1] as Article,
      typeService: fields[2] as TypeService?,
      tarifUsager: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TypeArticle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.article)
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
      other is TypeArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
