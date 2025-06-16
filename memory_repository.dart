import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img_lib;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:path/path.dart' as p;

import 'package:family_travel_app/core/firestore_service.dart';
import 'package:family_travel_app/core/logger.dart';
import 'package:family_travel_app/features/memory/data/memory_model.dart';

class LocalFile {
  final String path;
  final MemoryType type;
  final String? caption;
  final String localId; // Unique ID for local tracking

  LocalFile({required this.path, required this.type, this.caption, String? localId})
      : this.localId = localId ?? const Uuid().v4();
}

class MemoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirestoreService _firestoreService;

  MemoryRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirestoreService? firestoreService,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<Memory>> watchMemories(String planId, {int? limit}) {
    Query query = _firestore
        .collection('plans')
        .doc(planId)
        .collection('memories')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Memory.fromJson(doc.data())).toList());
  }

  Future<String> _generateThumb(String localFilePath) async {
    final file = File(localFilePath);
    final bytes = await file.readAsBytes();
    final image = img_lib.decodeImage(bytes);

    if (image == null) {
      throw Exception('Could not decode image for thumbnail generation');
    }

    final thumbnail = img_lib.copyResize(image, width: 400);
    final tempDir = await getTemporaryDirectory();
    final thumbPath = p.join(tempDir.path, '${const Uuid().v4()}_thumb.jpg');
    final thumbFile = File(thumbPath);
    await thumbFile.writeAsBytes(img_lib.encodeJpg(thumbnail, quality: 80));
    return thumbPath;
  }

  Future<Map<String, dynamic>> _compressAndUpload(String planId, String memoryId, String userId, LocalFile localFile) async {
    final storageRef = _storage.ref();
    final filePath = 'memories/$planId/$userId/$memoryId.${localFile.type == MemoryType.image ? 'jpg' : 'mp4'}';
    final fileRef = storageRef.child(filePath);

    int width = 0;
    int height = 0;
    int fileSize = 0;

    if (localFile.type == MemoryType.image) {
      final imageFile = File(localFile.path);
      final bytes = await imageFile.readAsBytes();
      final image = img_lib.decodeImage(bytes);
      if (image == null) {
        throw Exception('Could not decode image');
      }

      width = image.width;
      height = image.height;

      final resizedImage = img_lib.copyResize(image, width: 1600, height: (image.height * (1600 / image.width)).round());
      final compressedImageBytes = img_lib.encodeJpg(resizedImage, quality: 80);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, '$memoryId.jpg'));
      await tempFile.writeAsBytes(compressedImageBytes);
      fileSize = await tempFile.length();

      await fileRef.putFile(tempFile);
    } else {
      // TODO: Implement video re-encoding using ffmpeg_kit_flutter_min (Background isolate)
      // Ensure video is <= 10 MB. For now, just upload the original video file if it's within size limits.
      final videoFile = File(localFile.path);
      fileSize = await videoFile.length();
      // TODO: Get actual width/height for video from metadata
      await fileRef.putFile(videoFile);
    }

    final mediaUrl = await fileRef.getDownloadURL();
    // TODO: Use Firebase Storage Resize Extension for thumbUrl. While awaiting cloud thumb, use localThumb as placeholder and PATCH doc when remote ready
    final thumbUrl = mediaUrl; // Placeholder

    return {
      'mediaUrl': mediaUrl,
      'thumbUrl': thumbUrl,
      'width': width,
      'height': height,
      'fileSize': fileSize,
    };
  }

  Future<void> addMemories(String planId, String userId, List<LocalFile> localFiles) async {
    for (final localFile in localFiles) {
      final memoryId = const Uuid().v4();
      String? mediaUrl;
      String? thumbUrl;
      int width = 0;
      int height = 0;
      int fileSize = 0;

      try {
        final uploadResult = await _compressAndUpload(planId, memoryId, userId, localFile);
        mediaUrl = uploadResult['mediaUrl'];
        thumbUrl = uploadResult['thumbUrl'];
        width = uploadResult['width'];
        height = uploadResult['height'];
        fileSize = uploadResult['fileSize'];

        final newMemory = Memory(
          id: memoryId,
          type: localFile.type,
          mediaUrl: mediaUrl!,
          thumbUrl: thumbUrl!,
          width: width,
          height: height,
          caption: localFile.caption,
          createdAt: DateTime.now(), // Will be overwritten by serverTimestamp
          createdBy: userId,
          localId: localFile.localId, // Store localId for tracking
        );

        final batch = _firestore.batch();
        batch.set(
          _firestore.collection('plans').doc(planId).collection('memories').doc(memoryId),
          newMemory.toJson(),
        );
        batch.update(
          _firestore.collection('plans').doc(planId),
          {'updatedAt': FieldValue.serverTimestamp()},
        );
        await batch.commit();

        FirebaseAnalytics.instance.logEvent(
          name: 'memory_upload',
          parameters: {
            'type': localFile.type.name,
            'size': fileSize,
          },
        );
        AppLogger.log('Memory added: $memoryId for plan: $planId');
      } catch (e, st) {
        FirebaseCrashlytics.instance.recordError(e, st, reason: 'Error adding memory: ${localFile.path}');
        AppLogger.error('Error adding memory: ${localFile.path}', e, st);
        rethrow;
      }
    }
  }
}

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});


