// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snore_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SnoreRecordAdapter extends TypeAdapter<SnoreRecord> {
  @override
  final int typeId = 0;

  @override
  SnoreRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SnoreRecord(
      timestamp: fields[0] as DateTime,
      soundType: fields[1] as String,
      avgDb: fields[2] as double,
      maxDb: fields[3] as double,
      snoreDurationMs: fields[4] as int,
      audioFilePath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SnoreRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.soundType)
      ..writeByte(2)
      ..write(obj.avgDb)
      ..writeByte(3)
      ..write(obj.maxDb)
      ..writeByte(4)
      ..write(obj.snoreDurationMs)
      ..writeByte(5)
      ..write(obj.audioFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnoreRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
