// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanImpl _$$PlanImplFromJson(Map<String, dynamic> json) => _$PlanImpl(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      startDate:
          const TimestampConverter().fromJson(json['startDate'] as Timestamp),
      endDate:
          const TimestampConverter().fromJson(json['endDate'] as Timestamp),
      createdAt: const ServerTimestampConverter()
          .fromJson(json['createdAt'] as FieldValue),
      updatedAt: const ServerTimestampConverter()
          .fromJson(json['updatedAt'] as FieldValue),
      tzOffset: (json['tzOffset'] as num).toInt(),
      colour: json['colour'] as String?,
    );

Map<String, dynamic> _$$PlanImplToJson(_$PlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'familyId': instance.familyId,
      'title': instance.title,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
      'createdAt': const ServerTimestampConverter().toJson(instance.createdAt),
      'updatedAt': const ServerTimestampConverter().toJson(instance.updatedAt),
      'tzOffset': instance.tzOffset,
      'colour': instance.colour,
    };
