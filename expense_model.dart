import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:family_travel_app/features/expense/data/expense_category.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required ExpenseCategory category,
    required double amount,
    required String currency,
    required double jpyAmount,
    String? note,
    String? imageUrl,
    String? thumbUrl,
    @ServerTimestampConverter() required DateTime createdAt,
    required String createdBy,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

class ServerTimestampConverter implements JsonConverter<DateTime, FieldValue> {
  const ServerTimestampConverter();

  @override
  DateTime fromJson(FieldValue fieldValue) {
    // This method is not typically used for FieldValue.serverTimestamp()
    // as it's a write-only field. We'll return a dummy date or throw.
    throw UnimplementedError('ServerTimestampConverter.fromJson is not implemented.');
  }

  @override
  FieldValue toJson(DateTime date) => FieldValue.serverTimestamp();
}


