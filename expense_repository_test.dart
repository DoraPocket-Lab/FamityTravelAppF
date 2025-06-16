import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart'; // For BehaviorSubject

import 'package:family_travel_app/features/expense/data/expense_repository.dart';
import 'package:family_travel_app/features/expense/data/expense_category.dart';
import 'package:family_travel_app/features/expense/data/expense_model.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockReference extends Mock implements Reference {}
class MockUploadTask extends Mock implements UploadTask {}
class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  group('ExpenseRepository', () {
    late ExpenseRepository expenseRepository;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseStorage mockStorage;
    late MockCollectionReference mockPlansCollection;
    late MockDocumentReference mockPlanDoc;
    late MockCollectionReference mockExpensesCollection;
    late MockQuery mockExpensesQuery;
    late MockWriteBatch mockBatch;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockStorage = MockFirebaseStorage();
      mockPlansCollection = MockCollectionReference();
      mockPlanDoc = MockDocumentReference();
      mockExpensesCollection = MockCollectionReference();
      mockExpensesQuery = MockQuery();
      mockBatch = MockWriteBatch();

      when(mockFirestore.collection('plans')).thenReturn(mockPlansCollection);
      when(mockPlansCollection.doc(any)).thenReturn(mockPlanDoc);
      when(mockPlanDoc.collection('expenses')).thenReturn(mockExpensesCollection);
      when(mockExpensesCollection.orderBy(any, descending: anyNamed('descending'))).thenReturn(mockExpensesQuery);
      when(mockFirestore.batch()).thenReturn(mockBatch);

      // Mock storage for _uploadReceipt
      when(mockStorage.ref()).thenReturn(MockReference());
      when(mockStorage.ref().child(any)).thenReturn(MockReference());
      when(mockStorage.ref().child(any).putFile(any)).thenAnswer((_) async => MockUploadTask());
      when(mockStorage.ref().child(any).putFile(any).snapshot).thenReturn(MockTaskSnapshot());
      when(mockStorage.ref().child(any).getDownloadURL()).thenAnswer((_) async => 'http://example.com/image.jpg');

      expenseRepository = ExpenseRepository(
        firestore: mockFirestore,
        storage: mockStorage,
      );
    });

    test('addExpense performs batch write and uploads receipt', () async {
      final planId = 'testPlanId';
      final expenseDraft = ExpenseDraft(
        category: ExpenseCategory.food,
        amount: 100.0,
        currency: 'JPY',
        note: 'Lunch',
      );
      final testFile = File('test_receipt.jpg');

      await expenseRepository.addExpense(planId, expenseDraft, receiptFile: testFile);

      // Verify that a batch was created and committed
      verify(mockFirestore.batch()).called(1);
      verify(mockBatch.commit()).called(1);

      // Verify that set and update were called on the batch
      verify(mockBatch.set(any, any)).called(1); // For the new expense
      verify(mockBatch.update(any, any)).called(1); // For updating plan's updatedAt

      // Verify receipt upload was attempted
      verify(mockStorage.ref().child(argThat(startsWith('receipts/$planId/'))).putFile(any)).called(1);
    });

    test('addExpense performs batch write without receipt if not provided', () async {
      final planId = 'testPlanId';
      final expenseDraft = ExpenseDraft(
        category: ExpenseCategory.food,
        amount: 100.0,
        currency: 'JPY',
        note: 'Lunch',
      );

      await expenseRepository.addExpense(planId, expenseDraft);

      // Verify that a batch was created and committed
      verify(mockFirestore.batch()).called(1);
      verify(mockBatch.commit()).called(1);

      // Verify that set and update were called on the batch
      verify(mockBatch.set(any, any)).called(1); // For the new expense
      verify(mockBatch.update(any, any)).called(1); // For updating plan's updatedAt

      // Verify receipt upload was NOT attempted
      verifyNever(mockStorage.ref().child(any).putFile(any));
    });

    test('watchExpenses streams a list of expenses', () async {
      final planId = 'testPlanId';
      final mockExpenses = [
        Expense(
          id: 'exp1',
          category: ExpenseCategory.food,
          amount: 500.0,
          currency: 'JPY',
          jpyAmount: 500.0,
          createdAt: DateTime.now(),
          createdBy: 'user1',
        ),
        Expense(
          id: 'exp2',
          category: ExpenseCategory.transport,
          amount: 1000.0,
          currency: 'JPY',
          jpyAmount: 1000.0,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          createdBy: 'user1',
        ),
      ];

      final mockQuerySnapshot = MockQuerySnapshot();
      when(mockQuerySnapshot.docs).thenReturn(
        mockExpenses.map((e) {
          final mockDocSnapshot = MockDocumentSnapshot();
          when(mockDocSnapshot.data()).thenReturn(e.toJson());
          return mockDocSnapshot;
        }).toList(),
      );

      final behaviorSubject = BehaviorSubject<QuerySnapshot<Map<String, dynamic>>>.seeded(mockQuerySnapshot);
      when(mockExpensesQuery.snapshots()).thenAnswer((_) => behaviorSubject.stream);

      final expensesStream = expenseRepository.watchExpenses(planId);

      expect(expensesStream, emits(mockExpenses));

      // Simulate a new update
      final updatedExpenses = [
        ...mockExpenses,
        Expense(
          id: 'exp3',
          category: ExpenseCategory.other,
          amount: 200.0,
          currency: 'USD',
          jpyAmount: 22000.0, // Example conversion
          createdAt: DateTime.now().add(const Duration(hours: 1)),
          createdBy: 'user1',
        ),
      ];
      final updatedMockQuerySnapshot = MockQuerySnapshot();
      when(updatedMockQuerySnapshot.docs).thenReturn(
        updatedExpenses.map((e) {
          final mockDocSnapshot = MockDocumentSnapshot();
          when(mockDocSnapshot.data()).thenReturn(e.toJson());
          return mockDocSnapshot;
        }).toList(),
      );
      behaviorSubject.add(updatedMockQuerySnapshot);

      expect(expensesStream, emits(updatedExpenses));

      await behaviorSubject.close();
    });
  });
}


