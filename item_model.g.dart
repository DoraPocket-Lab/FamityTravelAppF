// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      planId: json['planId'] as String,
      day: const TimestampConverter().fromJson(json['day'] as Timestamp),
      startTime:
          const TimestampConverter().fromJson(json['startTime'] as Timestamp),
      endTime: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['endTime'], const TimestampConverter().fromJson),
      title: json['title'] as String,
      location: _$JsonConverterFromJson<Map<String, dynamic>, GeoPoint>(
          json['location'], const GeoPointConverter().fromJson),
      note: json['note'] as String?,
      sortIndex: (json['sortIndex'] as num).toInt(),
      createdBy: json['createdBy'] as String,
      createdAt: const ServerTimestampConverter()
          .fromJson(json['createdAt'] as FieldValue),
      updatedAt: const ServerTimestampConverter()
          .fromJson(json['updatedAt'] as FieldValue),
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'day': const TimestampConverter().toJson(instance.day),
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.endTime, const TimestampConverter().toJson),
      'title': instance.title,
      'location': _$JsonConverterToJson<Map<String, dynamic>, GeoPoint>(
          instance.location, const GeoPointConverter().toJson),
      'note': instance.note,
      'sortIndex': instance.sortIndex,
      'createdBy': instance.createdBy,
      'createdAt': const ServerTimestampConverter().toJson(instance.createdAt),
      'updatedAt': const ServerTimestampConverter().toJson(instance.updatedAt),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
