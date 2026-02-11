import 'package:json_annotation/json_annotation.dart';

part 'prayer_time.g.dart';

@JsonSerializable()
class DailyPrayerTimes {
  final Map<String, String> timings;
  final String date;
  final String hijriDate;
  final String dayName;
  final String? cityId;
  final String? cityName;

  DailyPrayerTimes({
    required this.timings,
    required this.date,
    required this.hijriDate,
    required this.dayName,
    this.cityId,
    this.cityName,
  });

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) =>
      _$DailyPrayerTimesFromJson(json);
  Map<String, dynamic> toJson() => _$DailyPrayerTimesToJson(this);

  // Helper to get formatted timings for UI
  String getFajr() => timings['Fajr'] ?? '--:--';
  String getSunrise() => timings['Sunrise'] ?? '--:--';
  String getDhuhr() => timings['Dhuhr'] ?? '--:--';
  String getAsr() => timings['Asr'] ?? '--:--';
  String getMaghrib() => timings['Maghrib'] ?? '--:--';
  String getIsha() => timings['Isha'] ?? '--:--';
}
