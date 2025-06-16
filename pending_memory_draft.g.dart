// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_memory_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingMemoryDraftAdapter extends TypeAdapter<PendingMemoryDraft> {
  @override
  final int typeId = 2;

  @override
  PendingMemoryDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingMemoryDraft(
      id: fields[0] as String,
      planId: fields[1] as String,
      localPath: fields[2] as String,
      type: fields[3] as MemoryType,
      caption: fields[4] as String?,
      userId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PendingMemoryDraft obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planId)
      ..writeByte(2)
      ..write(obj.localPath)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.caption)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMemoryDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
