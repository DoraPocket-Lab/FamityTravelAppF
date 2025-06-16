
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:family_travel_app/features/expense/presentation/widgets/expense_form_bottom_sheet.dart';
import 'package:family_travel_app/features/expense/controller/expense_notifier.dart';
import 'package:family_travel_app/features/expense/data/expense_category.dart';
import 'package:family_travel_app/features/expense/data/expense_repository.dart';
import 'package:family_travel_app/core/ocr_stub.dart';

// Mocks
class MockExpenseNotifier extends AutoDisposeStateNotifier<AsyncValue<List<Expense>>> with Mock implements ExpenseNotifier {
  MockExpenseNotifier(super.expenseRepository, super.planId);

  @override
  Future<void> addExpense(ExpenseDraft draft, {File? receiptFile}) async {
    // Simulate successful addition
    return Future.value();
  }
}

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  group('ExpenseFormBottomSheet Validation', () {
    late MockExpenseNotifier mockExpenseNotifier;
    late MockExpenseRepository mockExpenseRepository;

    setUp(() {
      mockExpenseRepository = MockExpenseRepository();
      mockExpenseNotifier = MockExpenseNotifier(mockExpenseRepository, 'testPlanId');
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          expenseNotifierProvider('testPlanId').overrideWith(
            (ref) => mockExpenseNotifier,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const ExpenseFormBottomSheet(planId: 'testPlanId'),
                  );
                },
                child: const Text('Show Form'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Save button is disabled when form is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Form'));
      await tester.pumpAndSettle();

      // Initially, the save button should be disabled because category and amount are empty
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);

      // Enter only amount, category is still null
      await tester.enterText(find.byType(TextFormField).at(1), '100.0');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);

      // Select category, amount is still empty
      await tester.enterText(find.byType(TextFormField).at(1), ''); // Clear amount
      await tester.tap(find.byType(DropdownButtonFormField<ExpenseCategory>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('FOOD').last); // Tap on the 'FOOD' option
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);
    });

    testWidgets('Save button is enabled when form is valid', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Form'));
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.byType(DropdownButtonFormField<ExpenseCategory>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('FOOD').last); // Tap on the 'FOOD' option
      await tester.pumpAndSettle();

      // Enter an amount
      await tester.enterText(find.byType(TextFormField).at(1), '123.45');
      await tester.pump();

      // Enter a currency
      await tester.enterText(find.byType(TextFormField).at(2), 'USD');
      await tester.pump();

      // Now the save button should be enabled
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNotNull);
    });

    testWidgets('OCR stub pre-fills fields and shows SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Form'));
      await tester.pumpAndSettle();

      // Mock image picker to return a dummy file
      final mockImagePicker = MockImagePicker();
      when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer((_) async => XFile('dummy_path.jpg'));

      // Mock scanReceipt to return deterministic data
      // Note: We cannot directly mock `scanReceipt` as it's a top-level function.
      // For testing purposes, we'll assume it's called and returns correctly.
      // In a real scenario, you might inject this dependency or use a test-specific stub.

      await tester.tap(find.text('Add Receipt Image'));
      await tester.pump(); // Start the future
      await tester.pumpAndSettle(); // Wait for the future to complete and UI to rebuild

      // Verify fields are pre-filled (based on OCR stub's deterministic data)
      expect(find.widgetWithText(TextFormField, '1234.0'), findsOneWidget); // Amount
      expect(find.text('FOOD'), findsOneWidget); // Category
      expect(find.widgetWithText(TextFormField, 'JPY'), findsOneWidget); // Currency

      // Verify SnackBar is shown
      expect(find.text('Receipt scanned!'), findsOneWidget);
    });
  });
}

class MockImagePicker extends Mock implements ImagePicker {}


