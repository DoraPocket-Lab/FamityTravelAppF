import 'package:hive/hive.dart';

import 'package:family_travel_app/features/expense/data/expense_category.dart';

part 'expense_draft.g.dart';

@HiveType(typeId: 1) // Unique typeId for ExpenseDraft
class ExpenseDraft extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String planId;
  @HiveField(2)
  final ExpenseCategory category;
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final String currency;
  @HiveField(5)
  final String? note;
  @HiveField(6)
  final String? receiptFilePath; // Local path to the receipt image

  ExpenseDraft({
    required this.id,
    required this.planId,
    required this.category,
    required this.amount,
    required this.currency,
    this.note,
    this.receiptFilePath,
  });
}


