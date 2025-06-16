import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:family_travel_app/core/firestore_service.dart';
import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/features/plan/data/plan_model.dart';
import 'package:family_travel_app/features/plan/data/item_model.dart';

class PlanRepository {
  final FirebaseFirestore _firestore;
  final FirestoreService _firestoreService;
  final FirebaseAuth _firebaseAuth;

  PlanRepository({
    FirebaseFirestore? firestore,
    FirestoreService? firestoreService,
    FirebaseAuth? firebaseAuth,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firestoreService = firestoreService ?? FirestoreService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<List<Plan>> watchPlans(String familyId) {
    return _firestore
        .collection('plans')
        .where('familyId', isEqualTo: familyId)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Plan.fromJson(doc.data())).toList());
  }

  Future<void> createPlan(Plan plan) async {
    try {
      await _firestoreService.setDocument('plans', plan.id, plan.toJson());
      AppLogger.log('Plan created: ${plan.id}');
    } catch (e, st) {
      AppLogger.error('Error creating plan: ${plan.id}', e, st);
      rethrow;
    }
  }

  Future<void> updatePlan(Plan plan) async {
    try {
      await _firestoreService.updateDocument('plans', plan.id, plan.toJson());
      AppLogger.log('Plan updated: ${plan.id}');
    } catch (e, st) {
      AppLogger.error('Error updating plan: ${plan.id}', e, st);
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _firestoreService.deleteDocument('plans', planId);
      AppLogger.log('Plan deleted: $planId');
    } catch (e, st) {
      AppLogger.error('Error deleting plan: $planId', e, st);
      rethrow;
    }
  }

  Stream<List<Item>> watchItems(String planId) {
    return _firestore
        .collection('plans')
        .doc(planId)
        .collection('items')
        .orderBy('day', descending: false)
        .orderBy('sortIndex', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList());
  }

  Future<void> createItem(String planId, Item item) async {
    try {
      await _firestoreService.setDocument(
          'plans/$planId/items', item.id, item.toJson());
      AppLogger.log('Item created: ${item.id} for plan: $planId');
    } catch (e, st) {
      AppLogger.error('Error creating item: ${item.id} for plan: $planId', e, st);
      rethrow;
    }
  }

  Future<void> updateItem(String planId, Item item) async {
    try {
      await _firestoreService.updateDocument(
          'plans/$planId/items', item.id, item.toJson());
      AppLogger.log('Item updated: ${item.id} for plan: $planId');
    } catch (e, st) {
      AppLogger.error('Error updating item: ${item.id} for plan: $planId', e, st);
      rethrow;
    }
  }

  Future<void> deleteItem(String planId, String itemId) async {
    try {
      await _firestoreService.deleteDocument(
          'plans/$planId/items', itemId);
      AppLogger.log('Item deleted: $itemId for plan: $planId');
    } catch (e, st) {
      AppLogger.error('Error deleting item: $itemId for plan: $planId', e, st);
      rethrow;
    }
  }

  Future<void> reorderItems(String planId, List<Item> items) async {
    final batch = _firestore.batch();
    for (var i = 0; i < items.length; i++) {
      final item = items[i].copyWith(sortIndex: i);
      batch.update(
          _firestore.collection('plans').doc(planId).collection('items').doc(item.id),
          item.toJson());
    }
    try {
      await batch.commit();
      AppLogger.log('Items reordered for plan: $planId');
    } catch (e, st) {
      AppLogger.error('Error reordering items for plan: $planId', e, st);
      rethrow;
    }
  }
}

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});


