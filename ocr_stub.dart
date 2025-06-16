import 'dart:io';
import 'dart:math';

import 'package:family_travel_app/features/expense/data/expense_model.dart';
import 'package:family_travel_app/features/expense/data/expense_category.dart';

class OcrResult {
  final double amount;
  final ExpenseCategory category;
  final String currency;

  OcrResult({
    required this.amount,
    required this.category,
    required this.currency,
  });
}

Future<OcrResult> scanReceipt(File img) async {
  // TODO: Replace with actual Cloud Vision API call in Phase 2
  // This is a deterministic stub based on timestamp seed
  final seed = DateTime.now().millisecondsSinceEpoch % 10000;
  final random = Random(seed);

  return Future.delayed(const Duration(seconds: 1), () {
    return OcrResult(
      amount: 1234.0 + random.nextInt(100),
      category: ExpenseCategory.food,
      currency: 'JPY',
    );
  });
}


