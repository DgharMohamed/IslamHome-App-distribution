// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adhkar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdhkarModel _$AdhkarModelFromJson(Map<String, dynamic> json) => AdhkarModel(
      id: json['id'] as String?,
      category: json['category'] as String?,
      text: json['text'] as String?,
      arabic: json['arabic'] as String?,
      zikr: json['zikr'] as String?,
      english: json['english'] as String?,
      count: json['count'],
      description: json['description'] as String?,
      reference: json['reference'] as String?,
    );

Map<String, dynamic> _$AdhkarModelToJson(AdhkarModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'text': instance.text,
      'arabic': instance.arabic,
      'zikr': instance.zikr,
      'english': instance.english,
      'count': instance.count,
      'description': instance.description,
      'reference': instance.reference,
    };
