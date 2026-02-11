// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithModel _$HadithModelFromJson(Map<String, dynamic> json) => HadithModel(
      id: json['id'] as String?,
      number: (json['hadithnumber'] as num?)?.toInt(),
      arab: json['text'] as String?,
      english: json['english'] as String?,
      narrator: json['narrator'] as String?,
      book: json['book'] as String?,
      chapter: json['chapter'] as String?,
      grade: json['grade'] as String?,
    );

Map<String, dynamic> _$HadithModelToJson(HadithModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hadithnumber': instance.number,
      'text': instance.arab,
      'english': instance.english,
      'narrator': instance.narrator,
      'book': instance.book,
      'chapter': instance.chapter,
      'grade': instance.grade,
    };

HadithBook _$HadithBookFromJson(Map<String, dynamic> json) => HadithBook(
      id: json['id'] as String?,
      name: json['name'] as String?,
      nameAr: json['nameAr'] as String?,
      available: (json['available'] as num?)?.toInt(),
      totalHadiths: (json['totalHadiths'] as num?)?.toInt(),
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => HadithChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HadithBookToJson(HadithBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'available': instance.available,
      'totalHadiths': instance.totalHadiths,
      'chapters': instance.chapters,
    };

HadithChapter _$HadithChapterFromJson(Map<String, dynamic> json) =>
    HadithChapter(
      name: json['name'] as String?,
      nameAr: json['nameAr'] as String?,
      hadiths: (json['hadiths'] as List<dynamic>?)
          ?.map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HadithChapterToJson(HadithChapter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAr': instance.nameAr,
      'hadiths': instance.hadiths,
    };
