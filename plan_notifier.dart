
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:uuid/uuid.dart';

import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/features/plan/data/plan_model.dart';
import 'package:family_travel_app/features/plan/data/item_model.dart';
import 'package:family_travel_app/features/plan/data/plan_repository.dart';

class PlanNotifier extends StateNotifier<AsyncValue<List<Plan>>> {
  final PlanRepository _planRepository;
  final String familyId;

  PlanNotifier(this._planRepository, this.familyId) : super(const AsyncValue.loading()) {
    _planRepository.watchPlans(familyId).listen(
      (plans) {
        state = AsyncValue.data(plans);
      },
      onError: (error, stackTrace) {
        AppLogger.error('Error watching plans', error, stackTrace);
        FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: 'Error watching plans');
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> createPlan(Plan plan) async {
    final previousState = state;
    state = AsyncValue.data([...state.value!, plan]); // Optimistic update
    try {
      await _planRepository.createPlan(plan);
      FirebaseAnalytics.instance.logEvent(name: 'plan_created', parameters: {'plan_id': plan.id});
    } catch (e, st) {
      AppLogger.error('Error creating plan', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error creating plan');
      state = previousState; // Revert on error
      rethrow;
    }
  }

  Future<void> updatePlan(Plan updatedPlan) async {
    final previousState = state;
    state = AsyncValue.data([
      for (final plan in state.value!)
        if (plan.id == updatedPlan.id) updatedPlan else plan,
    ]); // Optimistic update
    try {
      await _planRepository.updatePlan(updatedPlan);
    } catch (e, st) {
      AppLogger.error('Error updating plan', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error updating plan');
      state = previousState; // Revert on error
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    final previousState = state;
    state = AsyncValue.data(state.value!.where((plan) => plan.id != planId).toList()); // Optimistic update
    try {
      await _planRepository.deletePlan(planId);
    } catch (e, st) {
      AppLogger.error('Error deleting plan', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error deleting plan');
      state = previousState; // Revert on error
      rethrow;
    }
  }

  Future<void> createItem(String planId, Item item) async {
    // This optimistic update is more complex as items are nested.
    // For simplicity, we'll just re-fetch or update the specific plan's items later.
    // A more robust solution would involve managing item state within each plan.
    try {
      await _planRepository.createItem(planId, item);
      FirebaseAnalytics.instance.logEvent(name: 'item_created', parameters: {'plan_id': planId, 'item_id': item.id});
    } catch (e, st) {
      AppLogger.error('Error creating item', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error creating item');
      rethrow;
    }
  }

  Future<void> updateItem(String planId, Item updatedItem) async {
    try {
      await _planRepository.updateItem(planId, updatedItem);
    } catch (e, st) {
      AppLogger.error('Error updating item', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error updating item');
      rethrow;
    }
  }

  Future<void> deleteItem(String planId, String itemId) async {
    try {
      await _planRepository.deleteItem(planId, itemId);
    } catch (e, st) {
      AppLogger.error('Error deleting item', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error deleting item');
      rethrow;
    }
  }

  Future<void> reorderItems(String planId, List<Item> items) async {
    // Optimistic update for reordering is complex due to nested structure and sortIndex.
    // For now, we'll rely on the Firestore stream to update the UI after the batch write.
    try {
      await _planRepository.reorderItems(planId, items);
      FirebaseAnalytics.instance.logEvent(name: 'item_reordered', parameters: {'plan_id': planId});
    } catch (e, st) {
      AppLogger.error('Error reordering items', e, st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error reordering items');
      rethrow;
    }
  }
}

final planNotifierProvider = StateNotifierProvider.family<PlanNotifier, AsyncValue<List<Plan>>, String>(
  (ref, familyId) => PlanNotifier(ref.watch(planRepositoryProvider), familyId),
);

final selectedPlanProvider = StateProvider<Plan?>((ref) => null);

final currentPlanItemsProvider = StreamProvider.family<List<Item>, String>((ref, planId) {
  return ref.watch(planRepositoryProvider).watchItems(planId);
});


