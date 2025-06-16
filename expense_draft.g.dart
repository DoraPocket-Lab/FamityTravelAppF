// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseDraftAdapter extends TypeAdapter<ExpenseDraft> {
  @override
  final int typeId = 1;

  @override
  ExpenseDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseDraft(
      id: fields[0] as String,
      planId: fields[1] as String,
      category: fields[2] as ExpenseCategory,
      amount: fields[3] as double,
      currency: fields[4] as String,
      note: fields[5] as String?,
      receiptFilePath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseDraft obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.receiptFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
