
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:family_travel_app/features/expense/data/expense_model.dart';
import 'package:family_travel_app/features/expense/data/expense_category.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.lodging:
        return Icons.hotel;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.activity:
        return Icons.local_activity;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US', // TODO: Use user's locale or plan's currency locale
      symbol: expense.currency, // Use the actual currency symbol
      decimalDigits: 2,
    );

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getCategoryIcon(expense.category), size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  expense.category.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              currencyFormat.format(expense.amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (expense.note != null && expense.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  expense.note!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${DateFormat.yMd().format(expense.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


