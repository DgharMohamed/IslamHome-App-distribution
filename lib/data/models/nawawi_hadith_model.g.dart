// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nawawi_hadith_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NawawiHadith _$NawawiHadithFromJson(Map<String, dynamic> json) => NawawiHadith(
      number: (json['number'] as num?)?.toInt(),
      arabicText: json['arabicText'] as String?,
      englishTranslation: json['englishTranslation'] as String?,
      explanation: json['explanation'] as String?,
      reference: json['reference'] as String?,
      theme: json['theme'] as String?,
    );

Map<String, dynamic> _$NawawiHadithToJson(NawawiHadith instance) =>
    <String, dynamic>{
      'number': instance.number,
      'arabicText': instance.arabicText,
      'englishTranslation': instance.englishTranslation,
      'explanation': instance.explanation,
      'reference': instance.reference,
      'theme': instance.theme,
    };
