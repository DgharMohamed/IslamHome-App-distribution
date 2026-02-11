import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islamic_library_flutter/data/models/prayer_time.dart';

class HabousPrayerService {
  final Dio _dio = Dio();
  final String _baseUrl =
      'https://www.habous.gov.ma/prieres/horaire_hijri_2.php';
  final Box _cacheBox = Hive.box('prayer_times_cache');

  /// Fetches timings for a specific city for the current month.
  /// If [forceRefresh] is true, it bypasses the cache.
  Future<DailyPrayerTimes?> getTodayTimings(
    String cityId, {
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final cacheKey = 'habous_${cityId}_${now.year}_${now.month}';

    // 1. Try Cache
    if (!forceRefresh) {
      final cachedMap = _cacheBox.get(cacheKey);
      if (cachedMap != null && cachedMap is Map) {
        final dayKey = now.day.toString();
        if (cachedMap.containsKey(dayKey)) {
          return DailyPrayerTimes.fromJson(
            Map<String, dynamic>.from(cachedMap[dayKey]),
          );
        }
      }
    }

    // 2. Scrape from Habous
    try {
      debugPrint('Habous: Fetching fresh timings for city $cityId');
      final response = await _dio.get('$_baseUrl?ville=$cityId');
      if (response.statusCode == 200) {
        final document = parser.parse(response.data.toString());
        final table = document.getElementById('horaire');
        if (table == null) {
          debugPrint('Habous: Table not found in response');
          return null;
        }

        final rows = table.getElementsByTagName('tr');
        final Map<String, dynamic> monthData = {};

        for (var row in rows) {
          final cells = row.getElementsByTagName('td');
          if (cells.length < 9) continue;

          // Cell 2 is the Gregorian Day
          final gregDayStr = cells[2].text.trim();
          final dayNum = int.tryParse(gregDayStr);
          if (dayNum == null) continue;

          final timings = {
            'Fajr': _clean(cells[3].text),
            'Sunrise': _clean(cells[4].text),
            'Dhuhr': _clean(cells[5].text),
            'Asr': _clean(cells[6].text),
            'Maghrib': _clean(cells[7].text),
            'Isha': _clean(cells[8].text),
          };

          final daily = DailyPrayerTimes(
            timings: timings,
            date: '$gregDayStr-$now.month-$now.year',
            hijriDate: cells[1].text.trim(),
            dayName: cells[0].text.trim(),
            cityId: cityId,
          );

          monthData[gregDayStr] = daily.toJson();
        }

        if (monthData.isNotEmpty) {
          await _cacheBox.put(cacheKey, monthData);
          final todayKey = now.day.toString();
          if (monthData.containsKey(todayKey)) {
            return DailyPrayerTimes.fromJson(
              Map<String, dynamic>.from(monthData[todayKey]),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Habous Scraper Critical Error: $e');
    }

    return null;
  }

  String _clean(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
