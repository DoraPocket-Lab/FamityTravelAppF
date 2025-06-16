import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:family_travel_app/features/expense/controller/expense_notifier.dart';
import 'package:family_travel_app/features/expense/data/expense_model.dart';
import 'package:family_travel_app/features/expense/presentation/widgets/expense_card.dart';
import 'package:family_travel_app/features/expense/presentation/widgets/expense_form_bottom_sheet.dart';

class ExpenseTabScreen extends ConsumerWidget {
  final String planId;

  const ExpenseTabScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseNotifierProvider(planId));
    final totalSpend = ref.watch(totalInPlanCurrencyProvider(planId));
    // TODO: Get plan budget from plan_model or another provider
    const double planBudget = 10000.0; // Placeholder

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Column(
        children: [
          // Budget Progress Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spend: ${totalSpend.toStringAsFixed(2)} / ${planBudget.toStringAsFixed(2)} JPY',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: totalSpend / planBudget,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const Center(child: Text('No expenses yet. Add one!'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Staggered layout
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.5, // Adjust as needed
                  ),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseCard(expense: expense);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => ExpenseFormBottomSheet(planId: planId),
          );
        },
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}


