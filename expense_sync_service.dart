import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/features/expense/data/expense_draft.dart';
import 'package:family_travel_app/features/expense/data/expense_repository.dart';

class ExpenseSyncService {
  final ExpenseRepository _expenseRepository;
  final Connectivity _connectivity;
  late Box<ExpenseDraft> _pendingExpensesBox;
  StreamSubscription? _connectivitySubscription;

  ExpenseSyncService(this._expenseRepository, this._connectivity) {
    _init();
  }

  Future<void> _init() async {
    _pendingExpensesBox = await Hive.openBox<ExpenseDraft>('pendingExpenses');
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _processQueue();
      }
    });
    // Process queue immediately on startup
    _processQueue();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _pendingExpensesBox.close();
  }

  Future<void> queueExpense(ExpenseDraft draft, {File? receiptFile}) async {
    await _pendingExpensesBox.add(draft);
    AppLogger.log('Expense queued offline: ${draft.id}');
    // TODO: Show SnackBar 


  }

  Future<void> _processQueue() async {
    if (_pendingExpensesBox.isEmpty) return;

    AppLogger.log("Processing offline expense queue...");
    for (int i = 0; i < _pendingExpensesBox.length; i++) {
      final draft = _pendingExpensesBox.getAt(i);
      if (draft != null) {
        try {
          File? receiptFile;
          if (draft.receiptFilePath != null) {
            receiptFile = File(draft.receiptFilePath!);
            if (!await receiptFile.exists()) {
              AppLogger.warning("Receipt file not found for queued expense: ${draft.id}");
              // If file doesn't exist, try to add without it
              receiptFile = null;
            }
          }
          await _expenseRepository.addExpense(draft.planId, draft, receiptFile: receiptFile);
          await _pendingExpensesBox.deleteAt(i);
          AppLogger.log("Successfully processed queued expense: ${draft.id}");
        } catch (e, st) {
          AppLogger.error("Failed to process queued expense: ${draft.id}", e, st);
          // Keep in queue for retry
        }
      }
    }
  }
}

final expenseSyncServiceProvider = Provider<ExpenseSyncService>((ref) {
  return ExpenseSyncService(
    ref.watch(expenseRepositoryProvider),
    Connectivity(),
  );
});


