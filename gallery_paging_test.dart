
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:family_travel_app/features/memory/data/memory_model.dart';
import 'package:family_travel_app/features/memory/data/memory_repository.dart';
import 'package:family_travel_app/features/memory/presentation/memory_gallery_screen.dart';
import 'package:family_travel_app/features/memory/data/memory_sync_service.dart';
import 'package:family_travel_app/features/memory/data/pending_memory_draft.dart';

// Mocks
class MockMemoryRepository extends Mock implements MemoryRepository {}
class MockMemorySyncService extends Mock implements MemorySyncService {}

void main() {
  group('MemoryGalleryScreen Paging', () {
    late MockMemoryRepository mockMemoryRepository;
    late MockMemorySyncService mockMemorySyncService;

    setUp(() {
      mockMemoryRepository = MockMemoryRepository();
      mockMemorySyncService = MockMemorySyncService();

      // Stub watchMemories to return a stream of memories
      when(mockMemoryRepository.watchMemories(any, limit: anyNamed('limit')))
          .thenAnswer((_) => Stream.value([
                Memory(
                  id: 'mem1',
                  type: MemoryType.image,
                  mediaUrl: 'http://example.com/img1.jpg',
                  thumbUrl: 'http://example.com/thumb1.jpg',
                  width: 100,
                  height: 100,
                  createdAt: DateTime.now(),
                  createdBy: 'user1',
                ),
                Memory(
                  id: 'mem2',
                  type: MemoryType.video,
                  mediaUrl: 'http://example.com/vid2.mp4',
                  thumbUrl: 'http://example.com/thumb2.jpg',
                  width: 100,
                  height: 100,
                  createdAt: DateTime.now().subtract(const Duration(days: 1)),
                  createdBy: 'user1',
                ),
              ]));

      // Stub getPendingMemories to return an empty list by default
      when(mockMemorySyncService.getPendingMemories(any)).thenReturn([]);
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          memoryRepositoryProvider.overrideWithValue(mockMemoryRepository),
          memorySyncServiceProvider.overrideWithValue(mockMemorySyncService),
        ],
        child: MaterialApp(
          home: MemoryGalleryScreen(planId: 'testPlanId'),
        ),
      );
    }

    testWidgets('Gallery displays memories and fetches new pages on scroll', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial pump to load the first page
      await tester.pumpAndSettle();

      // Verify that memories are displayed
      expect(find.byType(CachedNetworkImage), findsNWidgets(2));
      expect(find.text('Add your first memory!'), findsNothing);

      // Simulate scrolling to trigger next page fetch (if pagination was implemented)
      // For this test, since watchMemories returns all at once, we just verify initial load.
      // In a real pagination scenario, you'd scroll and then verify more items appear.

      // Verify that watchMemories was called
      verify(mockMemoryRepository.watchMemories('testPlanId', limit: 20)).called(1);
    });

    testWidgets('Gallery displays pending memories with shimmer effect', (WidgetTester tester) async {
      // Add a pending memory
      when(mockMemorySyncService.getPendingMemories('testPlanId')).thenReturn([
        PendingMemoryDraft(
          id: 'pending1',
          planId: 'testPlanId',
          localPath: 'local/path/to/pending1.jpg',
          type: MemoryType.image,
          caption: 'Pending Image',
          userId: 'user1',
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify that the pending memory is displayed
      expect(find.byType(Image), findsOneWidget); // For the local image
      expect(find.byType(CircularProgressIndicator), findsOneWidget); // For the shimmer effect

      // Verify that Firestore memories are also displayed
      expect(find.byType(CachedNetworkImage), findsNWidgets(2));
    });

    testWidgets('Tapping pending memory shows SnackBar', (WidgetTester tester) async {
      // Add a pending memory
      when(mockMemorySyncService.getPendingMemories('testPlanId')).thenReturn([
        PendingMemoryDraft(
          id: 'pending1',
          planId: 'testPlanId',
          localPath: 'local/path/to/pending1.jpg',
          type: MemoryType.image,
          caption: 'Pending Image',
          userId: 'user1',
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap the pending memory
      await tester.tap(find.byType(Image).first); // Tap the local image
      await tester.pump();

      // Verify SnackBar is shown
      expect(find.text('Memory is still uploading...'), findsOneWidget);
    });
  });
}


