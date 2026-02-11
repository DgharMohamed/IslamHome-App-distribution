// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatma_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KhatmaPlan _$KhatmaPlanFromJson(Map<String, dynamic> json) => KhatmaPlan(
      targetDays: (json['targetDays'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      startPage: (json['startPage'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$KhatmaPlanToJson(KhatmaPlan instance) =>
    <String, dynamic>{
      'targetDays': instance.targetDays,
      'startDate': instance.startDate.toIso8601String(),
      'startPage': instance.startPage,
      'isCompleted': instance.isCompleted,
    };
