// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoryImpl _$$MemoryImplFromJson(Map<String, dynamic> json) => _$MemoryImpl(
      id: json['id'] as String,
      type: $enumDecode(_$MemoryTypeEnumMap, json['type']),
      mediaUrl: json['mediaUrl'] as String,
      thumbUrl: json['thumbUrl'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      caption: json['caption'] as String?,
      createdAt: const ServerTimestampConverter()
          .fromJson(json['createdAt'] as Object),
      createdBy: json['createdBy'] as String,
      localId: json['localId'] as String?,
    );

Map<String, dynamic> _$$MemoryImplToJson(_$MemoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MemoryTypeEnumMap[instance.type]!,
      'mediaUrl': instance.mediaUrl,
      'thumbUrl': instance.thumbUrl,
      'width': instance.width,
      'height': instance.height,
      'caption': instance.caption,
      'createdAt': const ServerTimestampConverter().toJson(instance.createdAt),
      'createdBy': instance.createdBy,
      'localId': instance.localId,
    };

const _$MemoryTypeEnumMap = {
  MemoryType.image: 'image',
  MemoryType.video: 'video',
};
