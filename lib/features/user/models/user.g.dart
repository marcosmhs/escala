// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      registration: fields[1] as String,
      password: fields[2] as String,
      name: fields[9] as String,
      gender: fields[10] as String,
      weekHours: fields[11] as int,
      dailyHours: fields[12] as int,
      active: fields[3] as bool,
      manager: fields[4] as bool,
      institutionResponsible: fields[5] as bool,
      institutionId: fields[6] as String,
      departmentId: fields[7] as String,
      needChangePassword: fields[8] as bool,
      lastScheduleDate: fields[13] as DateTime?,
      exclusionDate: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.registration)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.active)
      ..writeByte(4)
      ..write(obj.manager)
      ..writeByte(5)
      ..write(obj.institutionResponsible)
      ..writeByte(6)
      ..write(obj.institutionId)
      ..writeByte(7)
      ..write(obj.departmentId)
      ..writeByte(8)
      ..write(obj.needChangePassword)
      ..writeByte(9)
      ..write(obj.name)
      ..writeByte(10)
      ..write(obj.gender)
      ..writeByte(11)
      ..write(obj.weekHours)
      ..writeByte(12)
      ..write(obj.dailyHours)
      ..writeByte(13)
      ..write(obj.lastScheduleDate)
      ..writeByte(14)
      ..write(obj.exclusionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
