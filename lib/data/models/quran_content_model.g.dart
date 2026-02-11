// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuranEdition _$QuranEditionFromJson(Map<String, dynamic> json) => QuranEdition(
      identifier: json['identifier'] as String?,
      language: json['language'] as String?,
      name: json['name'] as String?,
      englishName: json['englishName'] as String?,
      format: json['format'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$QuranEditionToJson(QuranEdition instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'language': instance.language,
      'name': instance.name,
      'englishName': instance.englishName,
      'format': instance.format,
      'type': instance.type,
    };

QuranContent _$QuranContentFromJson(Map<String, dynamic> json) => QuranContent(
      number: (json['number'] as num?)?.toInt(),
      name: json['name'] as String?,
      ayahs: (json['ayahs'] as List<dynamic>?)
          ?.map((e) => Ayah.fromJson(e as Map<String, dynamic>))
          .toList(),
      surahs: (json['surahs'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(int.parse(k), Surah.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$QuranContentToJson(QuranContent instance) =>
    <String, dynamic>{
      'number': instance.number,
      'name': instance.name,
      'ayahs': instance.ayahs,
      'surahs': instance.surahs?.map((k, e) => MapEntry(k.toString(), e)),
    };

Ayah _$AyahFromJson(Map<String, dynamic> json) => Ayah(
      number: (json['number'] as num?)?.toInt(),
      text: json['text'] as String?,
      numberInSurah: (json['numberInSurah'] as num?)?.toInt(),
      juz: (json['juz'] as num?)?.toInt(),
      manzil: (json['manzil'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      ruku: (json['ruku'] as num?)?.toInt(),
      hizbQuarter: (json['hizbQuarter'] as num?)?.toInt(),
      sajda: json['sajda'],
      hizb: (json['hizb'] as num?)?.toInt(),
      rubu: (json['rubu'] as num?)?.toInt(),
      surah: json['surah'] == null
          ? null
          : Surah.fromJson(json['surah'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AyahToJson(Ayah instance) => <String, dynamic>{
      'number': instance.number,
      'text': instance.text,
      'numberInSurah': instance.numberInSurah,
      'juz': instance.juz,
      'manzil': instance.manzil,
      'page': instance.page,
      'ruku': instance.ruku,
      'hizbQuarter': instance.hizbQuarter,
      'sajda': instance.sajda,
      'hizb': instance.hizb,
      'rubu': instance.rubu,
      'surah': instance.surah,
    };
