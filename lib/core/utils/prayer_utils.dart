import 'package:islamic_library_flutter/data/models/prayer_times_model.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

class NextPrayerInfo {
  final String name;
  final String localizedName;
  final DateTime time;
  final Duration remaining;

  NextPrayerInfo({
    required this.name,
    required this.localizedName,
    required this.time,
    required this.remaining,
  });

  String get remainingTimeStr {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class PrayerUtils {
  static const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  static NextPrayerInfo? calculateNextPrayer(
    PrayerTimesModel data,
    AppLocalizations l10n,
  ) {
    if (data.timings == null) return null;

    final now = DateTime.now();
    final timings = data.timings!;

    final localizedNames = {
      'Fajr': l10n.fajr,
      'Dhuhr': l10n.dhuhr,
      'Asr': l10n.asr,
      'Maghrib': l10n.maghrib,
      'Isha': l10n.isha,
    };

    DateTime? nextPrayerTime;
    String nextName = "";

    for (var name in prayerNames) {
      final rawTime = timings[name];
      if (rawTime == null) continue;

      final timeStr = rawTime.split(' ')[0];
      final parts = timeStr.split(':');
      if (parts.length < 2) continue;

      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now)) {
        if (nextPrayerTime == null) {
          nextPrayerTime = prayerTime;
          nextName = name;
        }
      }
    }

    // If no more prayers today, next is Fajr tomorrow
    if (nextPrayerTime == null) {
      final rawFajr = timings['Fajr'];
      if (rawFajr != null) {
        final timeStr = rawFajr.split(' ')[0];
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          nextPrayerTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          nextName = 'Fajr';
        }
      }
    }

    if (nextPrayerTime != null) {
      return NextPrayerInfo(
        name: nextName,
        localizedName: localizedNames[nextName] ?? nextName,
        time: nextPrayerTime,
        remaining: nextPrayerTime.difference(now),
      );
    }

    return null;
  }
}
