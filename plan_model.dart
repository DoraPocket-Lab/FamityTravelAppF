import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    required String id,
    required String familyId,
    required String title,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    @ServerTimestampConverter() required DateTime createdAt,
    @ServerTimestampConverter() required DateTime updatedAt,
    required int tzOffset,
    String? colour,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

class ServerTimestampConverter implements JsonConverter<DateTime, FieldValue> {
  const ServerTimestampConverter();

  @override
  DateTime fromJson(FieldValue fieldValue) {
    // This method is not typically used for FieldValue.serverTimestamp()
    // as it's a write-only field. We'll return a dummy date or throw.
    throw UnimplementedError('ServerTimestampConverter.fromJson is not implemented.');
  }

  @override
  FieldValue toJson(DateTime date) => FieldValue.serverTimestamp();
}


