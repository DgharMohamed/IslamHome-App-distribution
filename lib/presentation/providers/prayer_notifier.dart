import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_library_flutter/data/models/prayer_time.dart';
import 'package:islamic_library_flutter/data/services/api_service.dart';
import 'package:islamic_library_flutter/data/services/offline_prayer_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PrayerState {
  final AsyncValue<DailyPrayerTimes?> timings;
  final String city;
  final String country;
  final String? habousId;
  final bool useGPS;

  PrayerState({
    required this.timings,
    required this.city,
    required this.country,
    this.habousId,
    this.useGPS = false,
  });

  PrayerState copyWith({
    AsyncValue<DailyPrayerTimes?>? timings,
    String? city,
    String? country,
    String? habousId,
    bool? useGPS,
  }) {
    return PrayerState(
      timings: timings ?? this.timings,
      city: city ?? this.city,
      country: country ?? this.country,
      habousId: habousId ?? this.habousId,
      useGPS: useGPS ?? this.useGPS,
    );
  }
}

class PrayerNotifier extends Notifier<PrayerState> {
  final ApiService _apiService = ApiService();
  final OfflinePrayerService _offlineService = OfflinePrayerService();

  @override
  PrayerState build() {
    final box = Hive.box('settings');
    final city = box.get('prayer_city', defaultValue: 'Rabat');
    final country = box.get('prayer_country', defaultValue: 'Morocco');
    final habousId = box.get('prayer_habous_id', defaultValue: '1');
    final useGPS = box.get('prayer_use_gps', defaultValue: false);

    // Load initial data
    Future.microtask(() => refresh());

    return PrayerState(
      timings: const AsyncValue.loading(),
      city: city,
      country: country,
      habousId: habousId,
      useGPS: useGPS,
    );
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    state = state.copyWith(timings: const AsyncValue.loading());

    try {
      DailyPrayerTimes? times;

      // 1. Primary source: AlAdhan API
      //    GET https://api.aladhan.com/v1/timingsByCity?city=X&country=Y&method=3
      try {
        final aladhan = await _apiService.getPrayerTimesByCity(
          state.city,
          state.country,
        );
        if (aladhan != null && aladhan.timings != null) {
          times = DailyPrayerTimes(
            timings: aladhan.timings!,
            date: aladhan.date?.gregorian?.date ?? '',
            hijriDate: aladhan.date?.hijri?.date ?? '',
            dayName: aladhan.date?.gregorian?.day ?? '',
            cityName: state.city,
          );
          // Cache the result in Hive for offline use
          await _cacheTimings(times);
          debugPrint('🕌 Prayer times loaded from AlAdhan API');
        }
      } catch (e) {
        debugPrint('🕌 AlAdhan API failed: $e');
      }

      // 2. Fallback: Last cached result from Hive
      if (times == null) {
        times = _getCachedTimings();
        if (times != null) {
          debugPrint('🕌 Prayer times loaded from cache');
        }
      }

      // 3. Final fallback: Offline calculation using adhan package
      if (times == null) {
        final box = Hive.box('settings');
        final lat = box.get('prayer_lat', defaultValue: 34.0209);
        final lng = box.get('prayer_lng', defaultValue: -6.8416);
        final offlineResult = _offlineService.calculatePrayerTimes(
          latitude: (lat as num).toDouble(),
          longitude: (lng as num).toDouble(),
        );
        if (offlineResult.timings != null) {
          times = DailyPrayerTimes(
            timings: offlineResult.timings!,
            date: offlineResult.date?.gregorian?.date ?? '',
            hijriDate: offlineResult.date?.hijri?.date ?? '',
            dayName: offlineResult.date?.gregorian?.day ?? '',
            cityName: state.city,
          );
          debugPrint('🕌 Prayer times calculated offline');
        }
      }

      state = state.copyWith(timings: AsyncValue.data(times));
    } catch (e, st) {
      state = state.copyWith(timings: AsyncValue.error(e, st));
    }
  }

  /// Cache prayer times in Hive for offline access.
  Future<void> _cacheTimings(DailyPrayerTimes times) async {
    try {
      final box = Hive.box('prayer_times_cache');
      await box.put('last_timings', times.timings);
      await box.put('last_date', times.date);
      await box.put('last_hijri_date', times.hijriDate);
      await box.put('last_day_name', times.dayName);
      await box.put('last_city_name', times.cityName);
      await box.put('cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('❌ Failed to cache prayer times: $e');
    }
  }

  /// Retrieve cached prayer times from Hive.
  DailyPrayerTimes? _getCachedTimings() {
    try {
      final box = Hive.box('prayer_times_cache');
      final timings = box.get('last_timings');
      if (timings == null) return null;

      return DailyPrayerTimes(
        timings: Map<String, String>.from(timings),
        date: box.get('last_date', defaultValue: ''),
        hijriDate: box.get('last_hijri_date', defaultValue: ''),
        dayName: box.get('last_day_name', defaultValue: ''),
        cityName: box.get('last_city_name', defaultValue: ''),
      );
    } catch (e) {
      debugPrint('❌ Failed to read cached prayer times: $e');
      return null;
    }
  }

  Future<void> updateLocation({
    required String city,
    required String country,
    String? habousId,
    double? latitude,
    double? longitude,
  }) async {
    final box = Hive.box('settings');
    await box.put('prayer_city', city);
    await box.put('prayer_country', country);
    if (habousId != null) await box.put('prayer_habous_id', habousId);
    if (latitude != null) await box.put('prayer_lat', latitude);
    if (longitude != null) await box.put('prayer_lng', longitude);

    state = state.copyWith(
      city: city,
      country: country,
      habousId: habousId,
      useGPS: false,
    );

    await refresh();
  }
}

final prayerNotifierProvider = NotifierProvider<PrayerNotifier, PrayerState>(
  () {
    return PrayerNotifier();
  },
);
