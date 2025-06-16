import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:family_travel_app/features/memory/data/memory_repository.dart';
import 'package:family_travel_app/features/memory/data/memory_sync_service.dart';
import 'package:family_travel_app/features/memory/data/pending_memory_draft.dart';
import 'package:family_travel_app/features/memory/data/memory_model.dart';

// Mocks
class MockMemoryRepository extends Mock implements MemoryRepository {}
class MockConnectivity extends Mock implements Connectivity {}
class MockBox extends Mock implements Box<PendingMemoryDraft> {}

void main() {
  group('MemorySyncService', () {
    late MockMemoryRepository mockMemoryRepository;
    late MockConnectivity mockConnectivity;
    late MockBox mockPendingMemoriesBox;
    late MemorySyncService memorySyncService;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      Hive.registerAdapter(PendingMemoryDraftAdapter());
      Hive.registerAdapter(MemoryTypeAdapter()); // Register MemoryTypeAdapter
    });

    setUp(() {
      mockMemoryRepository = MockMemoryRepository();
      mockConnectivity = MockConnectivity();
      mockPendingMemoriesBox = MockBox();

      // Stub Hive.openBox to return our mock box
      when(Hive.openBox<PendingMemoryDraft>('pendingMemories'))
          .thenAnswer((_) async => mockPendingMemoriesBox);

      // Initialize MemorySyncService
      memorySyncService = MemorySyncService(mockMemoryRepository, mockConnectivity);
    });

    tearDown(() async {
      await memorySyncService.dispose();
      await Hive.deleteBox('pendingMemories');
    });

    test('queueMemory adds draft to Hive box', () async {
      final draft = PendingMemoryDraft(
        id: 'testId',
        planId: 'testPlanId',
        localPath: 'test/path.jpg',
        type: MemoryType.image,
        caption: 'Test Caption',
        userId: 'testUser',
      );

      await memorySyncService.queueMemory(draft);

      verify(mockPendingMemoriesBox.add(draft)).called(1);
    });

    test('processQueue processes pending memories when online', () async {
      final draft = PendingMemoryDraft(
        id: 'testId',
        planId: 'testPlanId',
        localPath: 'test/path.jpg',
        type: MemoryType.image,
        caption: 'Test Caption',
        userId: 'testUser',
      );

      when(mockPendingMemoriesBox.isEmpty).thenReturn(false);
      when(mockPendingMemoriesBox.length).thenReturn(1);
      when(mockPendingMemoriesBox.getAt(0)).thenReturn(draft);
      when(mockConnectivity.onConnectivityChanged).thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

      // Simulate connectivity change to trigger processing
      await memorySyncService.queueMemory(draft); // Queue it first
      await Future.delayed(Duration(milliseconds: 100)); // Allow stream to propagate

      verify(mockMemoryRepository.addMemories(
        draft.planId,
        draft.userId,
        [argThat(isA<LocalFile>())],
      )).called(1);
      verify(mockPendingMemoriesBox.deleteAt(0)).called(1);
    });

    test('processQueue does not process when offline', () async {
      final draft = PendingMemoryDraft(
        id: 'testId',
        planId: 'testPlanId',
        localPath: 'test/path.jpg',
        type: MemoryType.image,
        caption: 'Test Caption',
        userId: 'testUser',
      );

      when(mockPendingMemoriesBox.isEmpty).thenReturn(false);
      when(mockPendingMemoriesBox.length).thenReturn(1);
      when(mockPendingMemoriesBox.getAt(0)).thenReturn(draft);
      when(mockConnectivity.onConnectivityChanged).thenAnswer((_) => Stream.value(ConnectivityResult.none));

      // Simulate connectivity change to trigger processing
      await memorySyncService.queueMemory(draft); // Queue it first
      await Future.delayed(Duration(milliseconds: 100)); // Allow stream to propagate

      verifyNever(mockMemoryRepository.addMemories(any, any, any));
      verifyNever(mockPendingMemoriesBox.deleteAt(any));
    });

    test('getPendingMemories returns correct list', () async {
      final draft1 = PendingMemoryDraft(
        id: 'id1',
        planId: 'planA',
        localPath: 'path1',
        type: MemoryType.image,
        caption: 'cap1',
        userId: 'user1',
      );
      final draft2 = PendingMemoryDraft(
        id: 'id2',
        planId: 'planB',
        localPath: 'path2',
        type: MemoryType.video,
        caption: 'cap2',
        userId: 'user1',
      );
      final draft3 = PendingMemoryDraft(
        id: 'id3',
        planId: 'planA',
        localPath: 'path3',
        type: MemoryType.image,
        caption: 'cap3',
        userId: 'user2',
      );

      when(mockPendingMemoriesBox.values).thenReturn([draft1, draft2, draft3]);

      final result = memorySyncService.getPendingMemories('planA');
      expect(result.length, 2);
      expect(result.contains(draft1), isTrue);
      expect(result.contains(draft3), isTrue);
      expect(result.contains(draft2), isFalse);
    });
  });
}

// Adapter for MemoryType enum for Hive
class MemoryTypeAdapter extends TypeAdapter<MemoryType> {
  @override
  final int typeId = 3; // Unique typeId for MemoryType

  @override
  MemoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemoryType.image;
      case 1:
        return MemoryType.video;
      default:
        return MemoryType.image; // Default case
    }
  }

  @override
  void write(BinaryWriter writer, MemoryType obj) {
    switch (obj) {
      case MemoryType.image:
        writer.writeByte(0);
        break;
      case MemoryType.video:
        writer.writeByte(1);
        break;
    }
  }
}


