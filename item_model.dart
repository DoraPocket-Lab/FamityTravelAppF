import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String planId,
    @TimestampConverter() required DateTime day,
    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() DateTime? endTime,
    required String title,
    @GeoPointConverter() GeoPoint? location,
    String? note,
    required int sortIndex,
    required String createdBy,
    @ServerTimestampConverter() required DateTime createdAt,
    @ServerTimestampConverter() required DateTime updatedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
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
  DateTime fromFrom(FieldValue fieldValue) {
    throw UnimplementedError('ServerTimestampConverter.fromJson is not implemented.');
  }

  @override
  FieldValue toJson(DateTime date) => FieldValue.serverTimestamp();
}

class GeoPointConverter implements JsonConverter<GeoPoint, Map<String, dynamic>> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Map<String, dynamic> json) => GeoPoint(json['latitude'] as double, json['longitude'] as double);

  @override
  Map<String, dynamic> toJson(GeoPoint geoPoint) => {'latitude': geoPoint.latitude, 'longitude': geoPoint.longitude};
}


