
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:family_travel_app/features/plan/presentation/plan_board_screen.dart';
import 'package:family_travel_app/features/plan/data/item_model.dart';
import 'package:family_travel_app/features/plan/controller/plan_notifier.dart';
import 'package:family_travel_app/features/plan/data/plan_repository.dart';

// Mocks
class MockPlanNotifier extends Mock implements PlanNotifier {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('PlanBoardScreen Item Reorder Test', () {
    late MockPlanNotifier mockPlanNotifier;
    late List<Item> initialItems;

    setUp(() {
      mockPlanNotifier = MockPlanNotifier();
      initialItems = [
        Item(
          id: 'item1',
          planId: 'plan1',
          day: DateTime(2024, 1, 1),
          startTime: DateTime(2024, 1, 1, 9, 0),
          title: 'Activity 1',
          sortIndex: 0,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'item2',
          planId: 'plan1',
          day: DateTime(2024, 1, 1),
          startTime: DateTime(2024, 1, 1, 10, 0),
          title: 'Activity 2',
          sortIndex: 1,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'item3',
          planId: 'plan1',
          day: DateTime(2024, 1, 1),
          startTime: DateTime(2024, 1, 1, 11, 0),
          title: 'Activity 3',
          sortIndex: 2,
          createdBy: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockPlanNotifier.reorderItems(any, any)).thenAnswer((_) async {});
    });

    testWidgets('reordering items calls reorderItems on PlanNotifier', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            planNotifierProvider('plan1').overrideWith((ref) => mockPlanNotifier),
            currentPlanItemsProvider('plan1').overrideWith((ref) => Stream.value(initialItems)),
          ],
          child: const MaterialApp(
            home: GoRouter(routes: [], initialLocation: '/plan/plan1',),
            builder: (context, child) => PlanBoardScreen(planId: 'plan1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the ReorderableListView
      final reorderable = find.byType(ReorderableListView);
      expect(reorderable, findsOneWidget);

      // Drag 'Activity 1' to the position of 'Activity 2'
      await tester.drag(
        find.text('Activity 1'),
        const Offset(0.0, 100.0), // Drag down by 100 pixels (enough to pass Activity 2)
      );
      await tester.pumpAndSettle();

      // Verify that reorderItems was called with the correct arguments
      final captured = verify(mockPlanNotifier.reorderItems(captureAny, captureAny)).captured;
      final capturedPlanId = captured[0] as String;
      final capturedItems = captured[1] as List<Item>;

      expect(capturedPlanId, 'plan1');
      expect(capturedItems.length, 3);
      expect(capturedItems[0].title, 'Activity 2');
      expect(capturedItems[1].title, 'Activity 1');
      expect(capturedItems[2].title, 'Activity 3');

      // Assert sortIndex values after reorder
      expect(capturedItems[0].sortIndex, 0);
      expect(capturedItems[1].sortIndex, 1);
      expect(capturedItems[2].sortIndex, 2);
    });
  });
}


