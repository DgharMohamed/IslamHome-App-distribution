// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTimesModel _$PrayerTimesModelFromJson(Map<String, dynamic> json) =>
    PrayerTimesModel(
      timings: (json['timings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      date: json['date'] == null
          ? null
          : DateInfo.fromJson(json['date'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrayerTimesModelToJson(PrayerTimesModel instance) =>
    <String, dynamic>{
      'timings': instance.timings,
      'date': instance.date,
    };

DateInfo _$DateInfoFromJson(Map<String, dynamic> json) => DateInfo(
      gregorian: json['gregorian'] == null
          ? null
          : GregorianDate.fromJson(json['gregorian'] as Map<String, dynamic>),
      hijri: json['hijri'] == null
          ? null
          : HijriDate.fromJson(json['hijri'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DateInfoToJson(DateInfo instance) => <String, dynamic>{
      'gregorian': instance.gregorian,
      'hijri': instance.hijri,
    };

GregorianDate _$GregorianDateFromJson(Map<String, dynamic> json) =>
    GregorianDate(
      date: json['date'] as String?,
      format: json['format'] as String?,
      day: json['day'] as String?,
    );

Map<String, dynamic> _$GregorianDateToJson(GregorianDate instance) =>
    <String, dynamic>{
      'date': instance.date,
      'format': instance.format,
      'day': instance.day,
    };

HijriDate _$HijriDateFromJson(Map<String, dynamic> json) => HijriDate(
      date: json['date'] as String?,
      format: json['format'] as String?,
      day: json['day'] as String?,
      month: json['month'] as Map<String, dynamic>?,
      year: json['year'] as String?,
    );

Map<String, dynamic> _$HijriDateToJson(HijriDate instance) => <String, dynamic>{
      'date': instance.date,
      'format': instance.format,
      'day': instance.day,
      'month': instance.month,
      'year': instance.year,
    };
