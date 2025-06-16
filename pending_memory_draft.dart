import 'package:hive/hive.dart';

import 'package:family_travel_app/features/memory/data/memory_model.dart';

part 'pending_memory_draft.g.dart';

@HiveType(typeId: 2) // Unique typeId for PendingMemoryDraft
class PendingMemoryDraft extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String planId;
  @HiveField(2)
  final String localPath;
  @HiveField(3)
  final MemoryType type;
  @HiveField(4)
  final String? caption;
  @HiveField(5)
  final String userId; // Added to track which user uploaded it

  PendingMemoryDraft({
    required this.id,
    required this.planId,
    required this.localPath,
    required this.type,
    this.caption,
    required this.userId,
  });
}


