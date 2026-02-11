import 'package:json_annotation/json_annotation.dart';

part 'prayer_times_model.g.dart';

@JsonSerializable()
class PrayerTimesModel {
  final Map<String, String>? timings;
  final DateInfo? date;

  PrayerTimesModel({this.timings, this.date});

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerTimesModelToJson(this);
}

@JsonSerializable()
class DateInfo {
  final GregorianDate? gregorian;
  final HijriDate? hijri;

  DateInfo({this.gregorian, this.hijri});

  factory DateInfo.fromJson(Map<String, dynamic> json) =>
      _$DateInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DateInfoToJson(this);
}

@JsonSerializable()
class GregorianDate {
  final String? date;
  final String? format;
  final String? day;

  GregorianDate({this.date, this.format, this.day});

  factory GregorianDate.fromJson(Map<String, dynamic> json) =>
      _$GregorianDateFromJson(json);
  Map<String, dynamic> toJson() => _$GregorianDateToJson(this);
}

@JsonSerializable()
class HijriDate {
  final String? date;
  final String? format;
  final String? day;
  final Map<String, dynamic>? month;
  final String? year;

  HijriDate({this.date, this.format, this.day, this.month, this.year});

  factory HijriDate.fromJson(Map<String, dynamic> json) =>
      _$HijriDateFromJson(json);
  Map<String, dynamic> toJson() => _$HijriDateToJson(this);
}
