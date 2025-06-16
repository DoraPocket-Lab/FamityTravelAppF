import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_model.freezed.dart';
part 'memory_model.g.dart';

enum MemoryType {
  image,
  video,
}

@freezed
class Memory with _$Memory {
  const factory Memory({
    required String id,
    required MemoryType type,
    required String mediaUrl,
    required String thumbUrl,
    required int width,
    required int height,
    String? caption,
    @ServerTimestampConverter() required DateTime createdAt,
    required String createdBy,
    String? localId, // Added for offline tracking
  }) = _Memory;

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
}

class ServerTimestampConverter implements JsonConverter<DateTime, Object> {
  const ServerTimestampConverter();

  @override
  DateTime fromJson(Object timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    throw Exception('Invalid timestamp type: $timestamp');
  }

  @override
  FieldValue toJson(DateTime date) => FieldValue.serverTimestamp();
}


