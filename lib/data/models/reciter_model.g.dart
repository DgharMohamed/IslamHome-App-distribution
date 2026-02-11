// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reciter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reciter _$ReciterFromJson(Map<String, dynamic> json) => Reciter(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      letter: json['letter'] as String?,
      moshaf: (json['moshaf'] as List<dynamic>?)
          ?.map((e) => Moshaf.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReciterToJson(Reciter instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'letter': instance.letter,
      'moshaf': instance.moshaf?.map((e) => e.toJson()).toList(),
    };

Moshaf _$MoshafFromJson(Map<String, dynamic> json) => Moshaf(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      server: json['server'] as String?,
      surahTotal: (json['surah_total'] as num?)?.toInt(),
      moshafType: (json['moshaf_type'] as num?)?.toInt(),
      surahList: json['surah_list'] as String?,
    );

Map<String, dynamic> _$MoshafToJson(Moshaf instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'server': instance.server,
      'surah_total': instance.surahTotal,
      'moshaf_type': instance.moshafType,
      'surah_list': instance.surahList,
    };
