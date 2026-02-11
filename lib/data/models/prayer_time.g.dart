// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyPrayerTimes _$DailyPrayerTimesFromJson(Map<String, dynamic> json) =>
    DailyPrayerTimes(
      timings: Map<String, String>.from(json['timings'] as Map),
      date: json['date'] as String,
      hijriDate: json['hijriDate'] as String,
      dayName: json['dayName'] as String,
      cityId: json['cityId'] as String?,
      cityName: json['cityName'] as String?,
    );

Map<String, dynamic> _$DailyPrayerTimesToJson(DailyPrayerTimes instance) =>
    <String, dynamic>{
      'timings': instance.timings,
      'date': instance.date,
      'hijriDate': instance.hijriDate,
      'dayName': instance.dayName,
      'cityId': instance.cityId,
      'cityName': instance.cityName,
    };
