
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:family_travel_app/core/offline_write_queue.dart';
import 'package:family_travel_app/core/logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final OfflineWriteQueue _offlineWriteQueue;

  FirestoreService({FirebaseFirestore? firestore, OfflineWriteQueue? offlineWriteQueue})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _offlineWriteQueue = offlineWriteQueue ?? OfflineWriteQueue();

  Future<void> init() async {
    await _offlineWriteQueue.init();
    // Enable Firestore persistence
    _firestore.settings = const Settings(persistenceEnabled: true);

    // Listen for network changes and process queue when online
    _firestore.snapshotsInSync().listen((event) {
      if (event.metadata.isFromCache && !event.metadata.hasPendingWrites) {
        // Device is offline
        AppLogger.log('Firestore is offline. Changes will be queued.');
      } else if (!event.metadata.isFromCache && !event.metadata.hasPendingWrites) {
        // Device is online and all pending writes are committed
        AppLogger.log('Firestore is online. Processing queued changes.');
        _processOfflineQueue();
      }
    });
  }

  Future<void> _processOfflineQueue() async {
    if (_offlineWriteQueue.isEmpty) return;

    final operations = _offlineWriteQueue.dequeueAll();
    for (final op in operations) {
      try {
        if (op.operationType == 'set') {
          await _firestore.collection(op.collection).doc(op.documentId).set(op.data);
        } else if (op.operationType == 'update') {
          await _firestore.collection(op.collection).doc(op.documentId).update(op.data);
        } else if (op.operationType == 'delete') {
          await _firestore.collection(op.collection).doc(op.documentId).delete();
        }
        AppLogger.log('Successfully processed queued operation: ${op.operationType} on ${op.collection}/${op.documentId}');
      } catch (e) {
        AppLogger.error('Failed to process queued operation: ${op.operationType} on ${op.collection}/${op.documentId}', e, StackTrace.current);
        // Re-enqueue if processing fails (e.g., due to validation errors on server)
        await _offlineWriteQueue.enqueue(op);
      }
    }
  }

  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      AppLogger.log('Failed to set document online, queuing: $collection/$documentId');
      await _offlineWriteQueue.enqueue(OfflineOperation(collection: collection, documentId: documentId, data: data, operationType: 'set'));
    }
  }

  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      AppLogger.log('Failed to update document online, queuing: $collection/$documentId');
      await _offlineWriteQueue.enqueue(OfflineOperation(collection: collection, documentId: documentId, data: data, operationType: 'update'));
    }
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      AppLogger.log('Failed to delete document online, queuing: $collection/$documentId');
      await _offlineWriteQueue.enqueue(OfflineOperation(collection: collection, documentId: documentId, data: {}, operationType: 'delete'));
    }
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());


