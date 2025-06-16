import 'package:hive/hive.dart';

part 'offline_write_queue.g.dart';

@HiveType(typeId: 0)
class OfflineOperation extends HiveObject {
  @HiveField(0)
  final String collection;
  @HiveField(1)
  final String documentId;
  @HiveField(2)
  final Map<String, dynamic> data;
  @HiveField(3)
  final String operationType; // 'set', 'update', 'delete'

  OfflineOperation({
    required this.collection,
    required this.documentId,
    required this.data,
    required this.operationType,
  });
}

class OfflineWriteQueue {
  static const String _boxName = 'offlineOperations';
  late Box<OfflineOperation> _box;

  Future<void> init() async {
    _box = await Hive.openBox<OfflineOperation>(_boxName);
  }

  Future<void> enqueue(OfflineOperation operation) async {
    await _box.add(operation);
  }

  List<OfflineOperation> dequeueAll() {
    final operations = _box.values.toList();
    _box.clear(); // Clear the box after dequeuing
    return operations;
  }

  bool get isEmpty => _box.isEmpty;
}


