import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart'; // For SnackBar

import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/features/memory/data/memory_repository.dart';
import 'package:family_travel_app/features/memory/data/pending_memory_draft.dart';

class MemorySyncService {
  final MemoryRepository _memoryRepository;
  final Connectivity _connectivity;
  late Box<PendingMemoryDraft> _pendingMemoriesBox;
  StreamSubscription? _connectivitySubscription;

  MemorySyncService(this._memoryRepository, this._connectivity) {
    _init();
  }

  Future<void> _init() async {
    _pendingMemoriesBox = await Hive.openBox<PendingMemoryDraft>('pendingMemories');
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
    _pendingMemoriesBox.close();
  }

  Future<void> queueMemory(PendingMemoryDraft draft) async {
    await _pendingMemoriesBox.add(draft);
    AppLogger.log('Memory queued offline: ${draft.id}');
    // Show SnackBar "Memories queued (N)"
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Memories queued (${_pendingMemoriesBox.length})')), 
        );
      });
    }
  }

  Future<void> _processQueue() async {
    if (_pendingMemoriesBox.isEmpty) return;

    AppLogger.log("Processing offline memory queue...");
    for (int i = 0; i < _pendingMemoriesBox.length; i++) {
      final draft = _pendingMemoriesBox.getAt(i);
      if (draft != null) {
        try {
          final localFile = LocalFile(
            path: draft.localPath,
            type: draft.type,
            caption: draft.caption,
            localId: draft.id, // Pass localId to repository
          );
          await _memoryRepository.addMemories(draft.planId, draft.userId, [localFile]);
          await _pendingMemoriesBox.deleteAt(i);
          AppLogger.log("Successfully processed queued memory: ${draft.id}");
        } catch (e, st) {
          AppLogger.error("Failed to process queued memory: ${draft.id}", e, st);
          FirebaseCrashlytics.instance.recordError(e, st, reason: 'Failed to process queued memory: ${draft.id}');
          // Keep in queue for retry with exponential back-off (TODO)
        }
      }
    }
  }

  // For merging with Firestore stream
  List<PendingMemoryDraft> getPendingMemories(String planId) {
    return _pendingMemoriesBox.values.where((draft) => draft.planId == planId).toList();
  }
}

final memorySyncServiceProvider = Provider<MemorySyncService>((ref) {
  return MemorySyncService(
    ref.watch(memoryRepositoryProvider),
    Connectivity(),
  );
});


