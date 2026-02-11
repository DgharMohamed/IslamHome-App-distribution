// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatma_completion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KhatmaCompletion _$KhatmaCompletionFromJson(Map<String, dynamic> json) =>
    KhatmaCompletion(
      completionDate: DateTime.parse(json['completionDate'] as String),
      totalDays: (json['totalDays'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
    );

Map<String, dynamic> _$KhatmaCompletionToJson(KhatmaCompletion instance) =>
    <String, dynamic>{
      'completionDate': instance.completionDate.toIso8601String(),
      'totalDays': instance.totalDays,
      'startDate': instance.startDate.toIso8601String(),
    };
