import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:family_travel_app/core/firestore_service.dart';
import 'package:family_travel_app/features/plan/data/plan_model.dart';
import 'package:family_travel_app/features/plan/data/item_model.dart';
import 'package:family_travel_app/features/plan/data/plan_repository.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}
class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}
class MockQuery<T> extends Mock implements Query<T> {}
class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}
class MockQueryDocumentSnapshot<T> extends Mock implements QueryDocumentSnapshot<T> {}
class MockFirestoreService extends Mock implements FirestoreService {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  group('PlanRepository', () {
    late ProviderContainer container;
    late MockFirebaseFirestore mockFirestore;
    late MockFirestoreService mockFirestoreService;
    late MockFirebaseAuth mockFirebaseAuth;
    late PlanRepository planRepository;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockFirestoreService = MockFirestoreService();
      mockFirebaseAuth = MockFirebaseAuth();

      when(mockFirebaseAuth.currentUser).thenReturn(MockUser());

      container = ProviderContainer(
        overrides: [
          firestoreServiceProvider.overrideWithValue(mockFirestoreService),
        ],
      );

      planRepository = PlanRepository(
        firestore: mockFirestore,
        firestoreService: mockFirestoreService,
        firebaseAuth: mockFirebaseAuth,
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('watchPlans returns a stream of plans', () async {
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      final dummyPlan = Plan(
        id: 'plan1',
        familyId: 'family1',
        title: 'Test Plan',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tzOffset: 0,
      );

      when(mockFirestore.collection('plans')).thenReturn(mockCollection);
      when(mockCollection.where('familyId', isEqualTo: 'family1')).thenReturn(mockQuery);
      when(mockQuery.orderBy('startDate', descending: false)).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
      when(mockDocumentSnapshot.data()).thenReturn(dummyPlan.toJson());

      final plansStream = planRepository.watchPlans('family1');
      expect(await plansStream.first, [dummyPlan]);
    });

    test('createPlan calls setDocument on FirestoreService', () async {
      final dummyPlan = Plan(
        id: 'plan1',
        familyId: 'family1',
        title: 'Test Plan',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tzOffset: 0,
      );

      await planRepository.createPlan(dummyPlan);

      verify(mockFirestoreService.setDocument('plans', dummyPlan.id, dummyPlan.toJson())).called(1);
    });

    test('updatePlan calls updateDocument on FirestoreService', () async {
      final dummyPlan = Plan(
        id: 'plan1',
        familyId: 'family1',
        title: 'Updated Plan',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tzOffset: 0,
      );

      await planRepository.updatePlan(dummyPlan);

      verify(mockFirestoreService.updateDocument('plans', dummyPlan.id, dummyPlan.toJson())).called(1);
    });

    test('deletePlan calls deleteDocument on FirestoreService', () async {
      await planRepository.deletePlan('plan1');

      verify(mockFirestoreService.deleteDocument('plans', 'plan1')).called(1);
    });

    test('watchItems returns a stream of items', () async {
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();
      final mockSubCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      final dummyItem = Item(
        id: 'item1',
        planId: 'plan1',
        day: DateTime.now(),
        startTime: DateTime.now(),
        title: 'Test Item',
        sortIndex: 0,
        createdBy: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockFirestore.collection('plans')).thenReturn(mockCollection);
      when(mockCollection.doc('plan1')).thenReturn(mockDocument);
      when(mockDocument.collection('items')).thenReturn(mockSubCollection);
      when(mockSubCollection.orderBy('day', descending: false)).thenReturn(mockQuery);
      when(mockQuery.orderBy('sortIndex', descending: false)).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
      when(mockDocumentSnapshot.data()).thenReturn(dummyItem.toJson());

      final itemsStream = planRepository.watchItems('plan1');
      expect(await itemsStream.first, [dummyItem]);
    });

    test('createItem calls setDocument on FirestoreService', () async {
      final dummyItem = Item(
        id: 'item1',
        planId: 'plan1',
        day: DateTime.now(),
        startTime: DateTime.now(),
        title: 'Test Item',
        sortIndex: 0,
        createdBy: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await planRepository.createItem('plan1', dummyItem);

      verify(mockFirestoreService.setDocument('plans/plan1/items', dummyItem.id, dummyItem.toJson())).called(1);
    });

    test('updateItem calls updateDocument on FirestoreService', () async {
      final dummyItem = Item(
        id: 'item1',
        planId: 'plan1',
        day: DateTime.now(),
        startTime: DateTime.now(),
        title: 'Updated Item',
        sortIndex: 0,
        createdBy: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await planRepository.updateItem('plan1', dummyItem);

      verify(mockFirestoreService.updateDocument('plans/plan1/items', dummyItem.id, dummyItem.toJson())).called(1);
    });

    test('deleteItem calls deleteDocument on FirestoreService', () async {
      await planRepository.deleteItem('plan1', 'item1');

      verify(mockFirestoreService.deleteDocument('plans/plan1/items', 'item1')).called(1);
    });

    test('reorderItems uses a WriteBatch to update sortIndex', () async {
      final mockWriteBatch = MockWriteBatch();
      when(mockFirestore.batch()).thenReturn(mockWriteBatch);

      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();
      final mockSubCollection = MockCollectionReference<Map<String, dynamic>>();

      when(mockFirestore.collection('plans')).thenReturn(mockCollection);
      when(mockCollection.doc('plan1')).thenReturn(mockDocument);
      when(mockDocument.collection('items')).thenReturn(mockSubCollection);
      when(mockSubCollection.doc(any)).thenReturn(mockDocument);

      final item1 = Item(
        id: 'item1',
        planId: 'plan1',
        day: DateTime.now(),
        startTime: DateTime.now(),
        title: 'Item 1',
        sortIndex: 0,
        createdBy: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final item2 = Item(
        id: 'item2',
        planId: 'plan1',
        day: DateTime.now(),
        startTime: DateTime.now(),
        title: 'Item 2',
        sortIndex: 1,
        createdBy: 'user1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final reorderedItems = [item2, item1]; // Simulate reorder

      await planRepository.reorderItems('plan1', reorderedItems);

      verify(mockWriteBatch.update(any, any)).called(2);
      verify(mockWriteBatch.commit()).called(1);
    });
  });
}


