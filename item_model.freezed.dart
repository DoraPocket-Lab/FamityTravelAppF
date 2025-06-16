// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Item _$ItemFromJson(Map<String, dynamic> json) {
  return _Item.fromJson(json);
}

/// @nodoc
mixin _$Item {
  String get id => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get day => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endTime => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @GeoPointConverter()
  GeoPoint? get location => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int get sortIndex => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @ServerTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @ServerTimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemCopyWith<Item> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemCopyWith<$Res> {
  factory $ItemCopyWith(Item value, $Res Function(Item) then) =
      _$ItemCopyWithImpl<$Res, Item>;
  @useResult
  $Res call(
      {String id,
      String planId,
      @TimestampConverter() DateTime day,
      @TimestampConverter() DateTime startTime,
      @TimestampConverter() DateTime? endTime,
      String title,
      @GeoPointConverter() GeoPoint? location,
      String? note,
      int sortIndex,
      String createdBy,
      @ServerTimestampConverter() DateTime createdAt,
      @ServerTimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$ItemCopyWithImpl<$Res, $Val extends Item>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? day = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? title = null,
    Object? location = freezed,
    Object? note = freezed,
    Object? sortIndex = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      sortIndex: null == sortIndex
          ? _value.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemImplCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$$ItemImplCopyWith(
          _$ItemImpl value, $Res Function(_$ItemImpl) then) =
      __$$ItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String planId,
      @TimestampConverter() DateTime day,
      @TimestampConverter() DateTime startTime,
      @TimestampConverter() DateTime? endTime,
      String title,
      @GeoPointConverter() GeoPoint? location,
      String? note,
      int sortIndex,
      String createdBy,
      @ServerTimestampConverter() DateTime createdAt,
      @ServerTimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$ItemImplCopyWithImpl<$Res>
    extends _$ItemCopyWithImpl<$Res, _$ItemImpl>
    implements _$$ItemImplCopyWith<$Res> {
  __$$ItemImplCopyWithImpl(_$ItemImpl _value, $Res Function(_$ItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? day = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? title = null,
    Object? location = freezed,
    Object? note = freezed,
    Object? sortIndex = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      sortIndex: null == sortIndex
          ? _value.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemImpl implements _Item {
  const _$ItemImpl(
      {required this.id,
      required this.planId,
      @TimestampConverter() required this.day,
      @TimestampConverter() required this.startTime,
      @TimestampConverter() this.endTime,
      required this.title,
      @GeoPointConverter() this.location,
      this.note,
      required this.sortIndex,
      required this.createdBy,
      @ServerTimestampConverter() required this.createdAt,
      @ServerTimestampConverter() required this.updatedAt});

  factory _$ItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemImplFromJson(json);

  @override
  final String id;
  @override
  final String planId;
  @override
  @TimestampConverter()
  final DateTime day;
  @override
  @TimestampConverter()
  final DateTime startTime;
  @override
  @TimestampConverter()
  final DateTime? endTime;
  @override
  final String title;
  @override
  @GeoPointConverter()
  final GeoPoint? location;
  @override
  final String? note;
  @override
  final int sortIndex;
  @override
  final String createdBy;
  @override
  @ServerTimestampConverter()
  final DateTime createdAt;
  @override
  @ServerTimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Item(id: $id, planId: $planId, day: $day, startTime: $startTime, endTime: $endTime, title: $title, location: $location, note: $note, sortIndex: $sortIndex, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      day,
      startTime,
      endTime,
      title,
      location,
      note,
      sortIndex,
      createdBy,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      __$$ItemImplCopyWithImpl<_$ItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemImplToJson(
      this,
    );
  }
}

abstract class _Item implements Item {
  const factory _Item(
          {required final String id,
          required final String planId,
          @TimestampConverter() required final DateTime day,
          @TimestampConverter() required final DateTime startTime,
          @TimestampConverter() final DateTime? endTime,
          required final String title,
          @GeoPointConverter() final GeoPoint? location,
          final String? note,
          required final int sortIndex,
          required final String createdBy,
          @ServerTimestampConverter() required final DateTime createdAt,
          @ServerTimestampConverter() required final DateTime updatedAt}) =
      _$ItemImpl;

  factory _Item.fromJson(Map<String, dynamic> json) = _$ItemImpl.fromJson;

  @override
  String get id;
  @override
  String get planId;
  @override
  @TimestampConverter()
  DateTime get day;
  @override
  @TimestampConverter()
  DateTime get startTime;
  @override
  @TimestampConverter()
  DateTime? get endTime;
  @override
  String get title;
  @override
  @GeoPointConverter()
  GeoPoint? get location;
  @override
  String? get note;
  @override
  int get sortIndex;
  @override
  String get createdBy;
  @override
  @ServerTimestampConverter()
  DateTime get createdAt;
  @override
  @ServerTimestampConverter()
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
