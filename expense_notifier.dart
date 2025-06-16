import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';

import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/features/expense/data/expense_model.dart';
import 'package:family_travel_app/features/expense/data/expense_repository.dart';

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseRepository _expenseRepository;
  final String planId;

  ExpenseNotifier(this._expenseRepository, this.planId) : super(const AsyncValue.loading()) {
    _expenseRepository.watchExpenses(planId).listen(
      (expenses) {
        state = AsyncValue.data(expenses);
      },
      onError: (error, stackTrace) {
        AppLogger.error('Error watching expenses', error, stackTrace);
        FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: 'Error watching expenses');
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> addExpense(ExpenseDraft draft, {File? receiptFile}) async {
    try {
      await _expenseRepository.addExpense(planId, draft, receiptFile: receiptFile);
      FirebaseAnalytics.instance.logEvent(
        name: 'expense_add',
        parameters: {
          'category': draft.category.toString().split('.').last,
          'value': draft.amount,
          'currency': draft.currency,
        },
      );
    } catch (e, st) {
      AppLogger.error('Error adding expense', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error adding expense');
      rethrow;
    }
  }

  double get totalInPlanCurrency {
    return state.when(
      data: (expenses) {
        // Assuming all expenses are in the plan's currency for this calculation
        // TODO: Implement actual currency conversion if multiple currencies are allowed in a single plan
        return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      },
      loading: () => 0.0,
      error: (error, stack) => 0.0,
    );
  }

  double get totalInJPY {
    return state.when(
      data: (expenses) {
        return expenses.fold(0.0, (sum, expense) => sum + expense.jpyAmount);
      },
      loading: () => 0.0,
      error: (error, stack) => 0.0,
    );
  }
}

final expenseNotifierProvider = StateNotifierProvider.family<ExpenseNotifier, AsyncValue<List<Expense>>, String>(
  (ref, planId) => ExpenseNotifier(ref.watch(expenseRepositoryProvider), planId),
);

final totalInPlanCurrencyProvider = Provider.family<double, String>((ref, planId) {
  final expensesAsync = ref.watch(expenseNotifierProvider(planId));
  return expensesAsync.when(
    data: (expenses) {
      // Assuming all expenses are in the plan's currency for this calculation
      // TODO: Implement actual currency conversion if multiple currencies are allowed in a single plan
      return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    },
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});

final totalInJPYProvider = Provider.family<double, String>((ref, planId) {
  final expensesAsync = ref.watch(expenseNotifierProvider(planId));
  return expensesAsync.when(
    data: (expenses) {
      return expenses.fold(0.0, (sum, expense) => sum + expense.jpyAmount);
    },
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});


