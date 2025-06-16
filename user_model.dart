import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum TravelStyle {
  car,
  train,
  air,
}

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String familyId,
    required String displayName,
    String? photoURL,
    required int familySize,
    required List<int> childrenAges,
    required TravelStyle travelStyle,
    @ServerTimestampConverter() required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class Family with _$Family {
  const factory Family({
    required String id,
    required String ownerUid,
    required List<String> members,
    @Default('JPY') String currency,
    @ServerTimestampConverter() required DateTime createdAt,
  }) = _Family;

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
}

class ServerTimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const ServerTimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}


