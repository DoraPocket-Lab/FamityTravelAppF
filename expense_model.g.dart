// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      jpyAmount: (json['jpyAmount'] as num).toDouble(),
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      createdAt: const ServerTimestampConverter()
          .fromJson(json['createdAt'] as FieldValue),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'amount': instance.amount,
      'currency': instance.currency,
      'jpyAmount': instance.jpyAmount,
      'note': instance.note,
      'imageUrl': instance.imageUrl,
      'thumbUrl': instance.thumbUrl,
      'createdAt': const ServerTimestampConverter().toJson(instance.createdAt),
      'createdBy': instance.createdBy,
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.lodging: 'lodging',
  ExpenseCategory.food: 'food',
  ExpenseCategory.activity: 'activity',
  ExpenseCategory.other: 'other',
};
