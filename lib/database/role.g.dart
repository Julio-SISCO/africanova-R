// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoleAdapter extends TypeAdapter<Role> {
  @override
  final int typeId = 1;

  @override
  Role read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Role(
      id: fields[0] as int?,
      name: fields[1] as String,
      permissions: (fields[2] as List).cast<Permission>(),
      users: (fields[3] as List).cast<User>(),
    );
  }

  @override
  void write(BinaryWriter writer, Role obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.permissions)
      ..writeByte(3)
      ..write(obj.users);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
