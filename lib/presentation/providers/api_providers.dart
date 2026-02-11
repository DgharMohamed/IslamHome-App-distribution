import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/data/models/book_model.dart';
import 'package:islamic_library_flutter/data/services/api_service.dart';
import 'package:islamic_library_flutter/data/services/local_quran_service.dart';
import 'package:islamic_library_flutter/data/services/local_hadith_service.dart';
import 'package:islamic_library_flutter/data/services/local_adhkar_service.dart';
import 'package:islamic_library_flutter/data/services/quran_image_service.dart';
import 'package:islamic_library_flutter/data/services/offline_cache_service.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';
import 'package:islamic_library_flutter/data/models/adhkar_model.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:islamic_library_flutter/data/models/radio_model.dart';
import 'package:islamic_library_flutter/data/models/tv_model.dart';
import 'package:islamic_library_flutter/data/models/video_model.dart';
import 'package:islamic_library_flutter/data/models/riwaya_model.dart';
import 'package:islamic_library_flutter/presentation/providers/locale_provider.dart';

// --- Core Service Providers ---

final apiServiceProvider = Provider((ref) => ApiService());
final quranServiceProvider = Provider((ref) => LocalQuranService());
final quranImageServiceProvider = Provider((ref) => QuranImageService());
final hadithServiceProvider = Provider((ref) => LocalHadithService());
final azkarServiceProvider = Provider((ref) => LocalAdhkarService());
final cacheServiceProvider = Provider((ref) => OfflineCacheService());

// --- Reciters (Cache-then-Network) ---

final recitersProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'reciters_${locale.languageCode}';

  try {
    final reciters = await apiService.getReciters(
      language: locale.languageCode,
    );
    if (reciters.isNotEmpty) {
      // Cache on success
      await cache.saveToCache(
        cacheKey,
        reciters.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return reciters;
    }
  } catch (e) {
    debugPrint('📴 Reciters API failed, using cache: $e');
  }

  // Fallback to cache
  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => Reciter.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <Reciter>[];
});

// --- Surahs (Local-first) ---

final surahsProvider = FutureProvider((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // Surahs always return both names, UI handles selection
  return apiService.getSurahs();
});

// --- Radios (Cache-then-Network) ---

final radiosProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'radios_${locale.languageCode}';

  try {
    final radios = await apiService.getRadios(language: locale.languageCode);
    if (radios.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        radios.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return radios;
    }
  } catch (e) {
    debugPrint('📴 Radios API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => RadioModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <RadioModel>[];
});

// --- Live TV (Cache-then-Network) ---

final liveTVProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  const cacheKey = 'live_tv';

  try {
    final channels = await apiService.getLiveTV();
    if (channels.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        channels.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return channels;
    }
  } catch (e) {
    debugPrint('📴 LiveTV API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => TvModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <TvModel>[];
});

// --- Azkar (Local-first, already offline) ---

final azkarProvider = FutureProvider<Map<String, List<AdhkarModel>>>((
  ref,
) async {
  final azkarService = ref.watch(azkarServiceProvider);
  // Try local first
  final local = await azkarService.getLocalAzkar();
  if (local.isNotEmpty) return local;

  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAzkar();
});

// --- Duas (Local-first, already offline) ---

final duasProvider = FutureProvider<Map<String, List<AdhkarModel>>>((
  ref,
) async {
  final azkarService = ref.watch(azkarServiceProvider);
  // Try local first
  final local = await azkarService.getLocalDuas();
  if (local.isNotEmpty) return local;

  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDuas();
});

// --- Hadith Books (Local-first + API enrichment) ---

final hadithBooksProvider = FutureProvider((ref) async {
  final hadithService = ref.watch(hadithServiceProvider);

  // Always return local books first (instant, always available)
  final localBooks = await hadithService.getLocalBooks();

  // Try to enrich with API data in parallel (non-blocking)
  try {
    final apiService = ref.watch(apiServiceProvider);
    final apiBooks = await apiService.getHadithBooks();
    if (apiBooks.isNotEmpty) return apiBooks;
  } catch (e) {
    debugPrint('📴 Hadith books API failed, using local: $e');
  }

  return localBooks;
});

final localHadithBooksProvider = FutureProvider<List<HadithBook>>((ref) async {
  final hadithService = ref.watch(hadithServiceProvider);
  return hadithService.getLocalBooks();
});

// --- Hadiths (Local-first + API fallback) ---

/// Map from API edition names to local book keys
const _editionToLocalKey = {
  'ara-bukhari': 'bukhari',
  'ara-muslim': 'muslim',
  'ara-abudawud': 'abudawud',
  'ara-tirmidhi': 'tirmidhi',
  'ara-nasai': 'nasai',
  'ara-ibnmajah': 'ibnmajah',
  'ara-malik': 'malik',
};

final hadithsProvider = FutureProvider.family<List<HadithModel>, String>((
  ref,
  edition,
) async {
  final hadithService = ref.watch(hadithServiceProvider);

  // Resolve the local key from the API edition name
  final localKey = _editionToLocalKey[edition] ?? edition;

  // 1. Try local first (instant, offline-safe)
  final localHadiths = await hadithService.getHadithsByBook(localKey);
  if (localHadiths.isNotEmpty) return localHadiths;

  // 2. Fallback to API
  try {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getHadiths(edition);
  } catch (e) {
    debugPrint('📴 Hadiths API failed for $edition: $e');
    return <HadithModel>[];
  }
});

// --- Videos (Cache-then-Network) ---

final videosProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  const cacheKey = 'videos';

  try {
    final videos = await apiService.getVideos();
    if (videos.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        videos.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 3),
      );
      return videos;
    }
  } catch (e) {
    debugPrint('📴 Videos API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <VideoModel>[];
});

final videoTypesProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  const cacheKey = 'video_types';

  try {
    final types = await apiService.getVideoTypes();
    if (types.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        types.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return types;
    }
  } catch (e) {
    debugPrint('📴 VideoTypes API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => VideoType.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <VideoType>[];
});

// Note: prayerTimesProvider has been replaced by prayerNotifierProvider in presentation/providers/prayer_notifier.dart

// --- Books (Library) ---

final booksProvider =
    FutureProvider.family<List<BookModel>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final cache = ref.watch(cacheServiceProvider);
      final apiService = ref.watch(apiServiceProvider);
      final cacheKey = 'books_${params['type']}_${params['page']}';

      try {
        final books = await apiService.getLibraryItems(
          type: params['type'] ?? 'books',
          page: params['page'] ?? 1,
          limit: params['limit'] ?? 20,
        );
        if (books.isNotEmpty) {
          await cache.saveToCache(
            cacheKey,
            books.map((e) => e.toJson()).toList(),
            ttl: const Duration(days: 3),
          );
          return books;
        }
      } catch (e) {
        debugPrint('📴 Books API failed, using cache: $e');
      }

      final cached = cache.getFromCacheForce(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => BookModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return <BookModel>[];
    });

// --- Rewayat (Cache-then-Network) ---

final rewayatProvider = FutureProvider((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  final locale = ref.watch(localeProvider);
  final cacheKey = 'rewayat_${locale.languageCode}';

  try {
    final rewayat = await apiService.getRewayat(language: locale.languageCode);
    if (rewayat.isNotEmpty) {
      await cache.saveToCache(
        cacheKey,
        rewayat.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 7),
      );
      return rewayat;
    }
  } catch (e) {
    debugPrint('📴 Rewayat API failed, using cache: $e');
  }

  final cached = cache.getFromCacheForce(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((e) => Riwaya.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <Riwaya>[];
});
