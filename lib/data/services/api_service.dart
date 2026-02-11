import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';
import 'package:islamic_library_flutter/data/models/radio_model.dart';
import 'package:islamic_library_flutter/data/models/tv_model.dart';
import 'package:islamic_library_flutter/data/models/book_model.dart';
import 'package:islamic_library_flutter/data/models/prayer_times_model.dart';
import 'package:islamic_library_flutter/data/models/adhkar_model.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';
import 'package:islamic_library_flutter/data/models/video_model.dart';
import 'package:islamic_library_flutter/data/models/riwaya_model.dart';
import 'package:islamic_library_flutter/data/models/quran_content_model.dart';
import 'package:islamic_library_flutter/data/services/local_quran_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ApiService {
  final Dio _dio = Dio();
  final LocalQuranService _offlineQuran = LocalQuranService();

  static const String _recitersApi = 'https://mp3quran.net/api/v3';
  static const String _quranCdnApi =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';
  // Legacy API kept as ultimate fallback
  static const String _alQuranApi = 'https://api.alquran.cloud/v1';
  static const String _islamHouseApi = 'https://api.islamhouse.com/v1/page';
  static const String _hadithCdnApi =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
  static const String _hadithApiLegacy = 'https://api.hadith.gading.dev';

  // Edition mapping: old identifier -> new CDN identifier
  static const Map<String, String> _editionMap = {
    'quran-uthmani': 'ara-quranacademy',
    'quran-simple': 'ara-quransimple',
    'en.sahih': 'eng-ummmuhammad',
    'en.asad': 'eng-muhammadasad',
    'en.pickthall': 'eng-mohammedmarmadu',
    'en.yusufali': 'eng-abdullahyusufal',
    'en.hilali': 'eng-muhammadtaqiudd',
    'ar.jalalayn': 'ara-jalaladdinalmah',
    'ar.muyassar': 'ara-muyassar',
    'ar.tanweer': 'ara-tanweer',
    'ar.waseet': 'ara-waseet',
    'ur.ahmedali': 'urd-ahmedali',
    'tr.ates': 'tur-suleymanates',
    'fr.hamidullah': 'fra-muhammadhamidul',
    'tr.diyanet': 'tur-diyanetisleri',
    'ur.jalandhry': 'urd-fatehmuhammadja',
    'id.indonesian': 'ind-indonesianislam',
    'ru.kuliev': 'rus-elmirkuliev',
    'de.bubenheim': 'deu-asfbubenheimand',
    'es.cortes': 'spa-juliocortes',
  };

  static const Map<String, String> _hadithBookMap = {
    'bukhari': 'ara-bukhari',
    'muslim': 'ara-muslim',
    'abudawud': 'ara-abudawud',
    'tirmidhi': 'ara-tirmidhi',
    'nasai': 'ara-nasai',
    'ibnmajah': 'ara-ibnmajah',
    'malik': 'ara-malik',
    'ahmad': 'ara-ahmad',
    'darimi': 'ara-darimi',
  };

  // Cached Quran info for verse metadata
  Map<String, dynamic>? _cachedQuranInfo;
  Future<Map<String, dynamic>>? _infoFuture;

  // Cache for page data to avoid repeated processing/fetching
  final Map<int, QuranSurahContent> _pageCache = {};

  // --- Reciters Service ---
  Future<List<Reciter>> getReciters({
    String? rewaya,
    String language = 'ar',
  }) async {
    String url = '$_recitersApi/reciters?language=$language';
    if (rewaya != null) {
      url += '&rewaya=$rewaya';
    }

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reciters'];
        return data.map((json) => Reciter.fromJson(json)).toList();
      }
      throw Exception('Failed to load reciters');
    } catch (e) {
      debugPrint('API Error (getReciters): $e');
      rethrow;
    }
  }

  Future<List<Riwaya>> getRewayat({String language = 'ar'}) async {
    try {
      final response = await _dio.get(
        '$_recitersApi/riwayat?language=$language',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['riwayat'];
        return data.map((json) => Riwaya.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getRewayat): $e');
      return [];
    }
  }

  Future<List<RadioModel>> getRadios({String language = 'ar'}) async {
    try {
      final response = await _dio.get(
        '$_recitersApi/radios?language=$language',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['radios'];
        return data.map((json) => RadioModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getRadios): $e');
      return [];
    }
  }

  Future<List<TvModel>> getLiveTV() async {
    try {
      final response = await _dio.get('$_recitersApi/live-tv');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['livetv'];
        return data.map((json) => TvModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getLiveTV): $e');
      return [];
    }
  }

  // --- Library Service ---

  // --- Prayer Times Service ---
  Future<PrayerTimesModel?> getPrayerTimesByCity(
    String city,
    String country, {
    int method = 3,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.aladhan.com/v1/timingsByCity',
        queryParameters: {'city': city, 'country': country, 'method': method},
      );
      if (response.statusCode == 200) {
        return PrayerTimesModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('API Error (getPrayerTimesByCity): $e');
      return null;
    }
  }

  Future<PrayerTimesModel?> getPrayerTimesByLocation(
    double latitude,
    double longitude, {
    int method = 3,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.aladhan.com/v1/timings',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );
      if (response.statusCode == 200) {
        return PrayerTimesModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('API Error (getPrayerTimesByLocation): $e');
      return null;
    }
  }

  // --- Quran Service ---

  /// Resolves an edition identifier to the new CDN format.
  String _resolveEdition(String edition) {
    return _editionMap[edition] ?? edition;
  }

  /// Fetches and caches Quran info (chapters, verse metadata).
  Future<Map<String, dynamic>> _getQuranInfo() async {
    if (_cachedQuranInfo != null) return _cachedQuranInfo!;
    if (_infoFuture != null) return _infoFuture!;

    _infoFuture = (() async {
      try {
        final response = await _dio.get('$_quranCdnApi/info.min.json');
        if (response.statusCode == 200) {
          final data = response.data;
          _cachedQuranInfo = data is String
              ? await compute(_parseJson, data)
              : data as Map<String, dynamic>;
          return _cachedQuranInfo!;
        }
      } catch (e) {
        debugPrint('Failed to fetch Quran info: $e');
      } finally {
        _infoFuture = null;
      }
      return <String, dynamic>{};
    })();

    return _infoFuture!;
  }

  // Helper for compute
  static Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<List<Surah>> getSurahs() async {
    // Try offline first
    try {
      return await _offlineQuran.getSurahs();
    } catch (e) {
      debugPrint('Offline surahs not available, fetching online: $e');
    }

    // Fallback to new CDN API
    try {
      final info = await _getQuranInfo();
      if (info.isNotEmpty && info['chapters'] != null) {
        final List<dynamic> chapters = info['chapters'];
        return chapters.map((ch) {
          return Surah.fromJson({
            'number': ch['chapter'],
            'name': ch['arabicname'] ?? ch['name'],
            'englishName': ch['englishname'] ?? ch['name'],
            'revelationType': ch['revelation'] ?? 'Mecca',
            'numberOfAyahs': (ch['verses'] as List?)?.length ?? 0,
          });
        }).toList();
      }
      throw Exception('Failed to load surahs from CDN');
    } catch (e) {
      debugPrint('CDN Error (getSurahs): $e');
      // Ultimate fallback to old API
      try {
        final response = await _dio.get('$_alQuranApi/surah');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data['data'];
          return data.map((json) => Surah.fromJson(json)).toList();
        }
      } catch (e2) {
        debugPrint('Legacy API Error (getSurahs): $e2');
      }
      rethrow;
    }
  }

  Future<List<QuranEdition>> getQuranEditions() async {
    try {
      final response = await _dio.get('$_quranCdnApi/editions.min.json');
      if (response.statusCode == 200) {
        final Map<String, dynamic> editionsMap =
            response.data as Map<String, dynamic>;
        return editionsMap.entries.map((entry) {
          final ed = entry.value as Map<String, dynamic>;
          return QuranEdition(
            identifier: ed['name'] as String?,
            language: ed['language'] as String?,
            name: ed['author'] as String?,
            englishName: ed['author'] as String?,
            format: 'text',
            type:
                (ed['direction'] == 'rtl' &&
                    (ed['language'] as String?)?.toLowerCase() == 'arabic')
                ? 'quran'
                : 'translation',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('CDN Error (getQuranEditions): $e');
      // Fallback to old API
      try {
        final response = await _dio.get('$_alQuranApi/edition');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data['data'];
          return data
              .map((json) => QuranEdition.fromJson(json))
              .where((ed) => ed.format == 'text')
              .toList();
        }
      } catch (e2) {
        debugPrint('Legacy API Error (getQuranEditions): $e2');
      }
      return [];
    }
  }

  Future<QuranSurahContent?> getQuranSurah(
    int surahNumber, {
    String edition = 'ar.alafasy',
  }) async {
    // Try offline first for supported editions
    if (edition == 'quran-uthmani' || edition == 'en.sahih') {
      try {
        final offlineData = await _offlineQuran.getQuranSurah(
          surahNumber,
          edition: edition,
        );
        if (offlineData != null) return offlineData;
      } catch (e) {
        debugPrint('Offline surah not available, fetching online: $e');
      }
    }

    // Fetch from new CDN API
    try {
      final resolvedEdition = _resolveEdition(edition);
      final response = await _dio.get(
        '$_quranCdnApi/editions/$resolvedEdition/$surahNumber.min.json',
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> verses = data['chapter'] ?? [];

        // Get verse metadata from info endpoint
        final info = await _getQuranInfo();
        final List<dynamic>? chapters = info['chapters'] as List<dynamic>?;
        Map<String, dynamic>? chapterInfo;
        List<dynamic>? verseMeta;
        if (chapters != null && surahNumber <= chapters.length) {
          chapterInfo = chapters[surahNumber - 1] as Map<String, dynamic>;
          verseMeta = chapterInfo['verses'] as List<dynamic>?;
        }

        final ayahs = verses.map((v) {
          final verseNum = v['verse'] as int;
          // Get metadata for this verse
          Map<String, dynamic>? meta;
          if (verseMeta != null && verseNum <= verseMeta.length) {
            meta = verseMeta[verseNum - 1] as Map<String, dynamic>;
          }
          return Ayah(
            number: verseNum,
            text: v['text'] as String?,
            numberInSurah: verseNum,
            juz: meta?['juz'] as int?,
            manzil: meta?['manzil'] as int?,
            page: meta?['page'] as int?,
            ruku: meta?['ruku'] as int?,
            hizbQuarter: meta?['maqra'] as int?,
            sajda: meta?['sajda'],
            hizb: meta?['maqra'] != null
                ? ((meta!['maqra'] as int) - 1) ~/ 4 + 1
                : null,
          );
        }).toList();

        return QuranSurahContent(
          number: surahNumber,
          name:
              chapterInfo?['arabicname'] as String? ??
              chapterInfo?['name'] as String?,
          ayahs: ayahs,
        );
      }
    } catch (e) {
      debugPrint('CDN Error (getQuranSurah): $e');
    }

    // Ultimate fallback to old API
    try {
      final response = await _dio.get(
        '$_alQuranApi/surah/$surahNumber/$edition',
      );
      if (response.statusCode == 200) {
        return QuranSurahContent.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint('Legacy API Error (getQuranSurah): $e');
    }
    return null;
  }

  Future<QuranSurahContent?> getQuranPage(
    int pageNumber, {
    String edition = 'quran-uthmani',
  }) async {
    // Check memory cache first
    if (_pageCache.containsKey(pageNumber)) return _pageCache[pageNumber];

    // Try offline first
    if (edition == 'quran-uthmani') {
      try {
        final offlineData = await _offlineQuran.getQuranPage(
          pageNumber,
          edition: edition,
        );
        if (offlineData != null) return offlineData;
      } catch (e) {
        debugPrint('Offline page not available, fetching online: $e');
      }
    }

    // Fetch page from CDN by finding which surahs/verses belong to this page
    try {
      final info = await _getQuranInfo();
      final List<dynamic>? chapters = info['chapters'] as List<dynamic>?;
      if (chapters == null) throw Exception('No chapter info available');

      final resolvedEdition = _resolveEdition(edition);
      final List<Ayah> pageAyahs = [];

      // Find all verses on this page
      for (final ch in chapters) {
        final chapterNum = ch['chapter'] as int;
        final List<dynamic> verses = ch['verses'] as List<dynamic>;
        final versesOnPage = verses.where((v) => v['page'] == pageNumber);

        if (versesOnPage.isNotEmpty) {
          // Fetch the chapter text for this edition
          try {
            final response = await _dio.get(
              '$_quranCdnApi/editions/$resolvedEdition/$chapterNum.min.json',
            );
            if (response.statusCode == 200) {
              final data = response.data as Map<String, dynamic>;
              final List<dynamic> chapterVerses = data['chapter'] ?? [];

              for (final meta in versesOnPage) {
                final verseNum = meta['verse'] as int;
                String? text;
                for (final cv in chapterVerses) {
                  if (cv['verse'] == verseNum) {
                    text = cv['text'] as String?;
                    break;
                  }
                }
                pageAyahs.add(
                  Ayah(
                    number: verseNum,
                    text: text,
                    numberInSurah: verseNum,
                    juz: meta['juz'] as int?,
                    manzil: meta['manzil'] as int?,
                    page: meta['page'] as int?,
                    ruku: meta['ruku'] as int?,
                    hizbQuarter: meta['maqra'] as int?,
                    sajda: meta['sajda'],
                    hizb: meta['maqra'] != null
                        ? ((meta['maqra'] as int) - 1) ~/ 4 + 1
                        : null,
                    surah: Surah(
                      number: chapterNum,
                      name: ch['arabicname'] as String?,
                      englishName: ch['englishname'] as String?,
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Error fetching chapter $chapterNum for page: $e');
          }
        }
      }

      if (pageAyahs.isNotEmpty) {
        final content = QuranSurahContent(number: pageNumber, ayahs: pageAyahs);
        _pageCache[pageNumber] = content;
        return content;
      }
    } catch (e) {
      debugPrint('CDN Error (getQuranPage): $e');
    }

    // Ultimate fallback to old API
    try {
      final response = await _dio.get('$_alQuranApi/page/$pageNumber/$edition');
      if (response.statusCode == 200) {
        return QuranSurahContent.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint('Legacy API Error (getQuranPage): $e');
    }
    return null;
  }

  Future<List<QuranEdition>> getTafsirEditions() async {
    // The new CDN API doesn't have a separate tafsir endpoint,
    // so we return known tafsir editions from the editions list.
    const tafsirEditions = [
      {
        'identifier': 'ara-jalaladdinalmah',
        'name': 'Tafsir al-Jalalayn',
        'language': 'Arabic',
      },
      {
        'identifier': 'ara-kingfahadquranc',
        'name': 'King Fahad Quran Complex',
        'language': 'Arabic',
      },
      {
        'identifier': 'ara-sirajtafseer',
        'name': 'Siraj Tafseer',
        'language': 'Arabic',
      },
      {
        'identifier': 'ind-jalaladdinalmah',
        'name': 'Tafsir al-Jalalayn (Indonesian)',
        'language': 'Indonesian',
      },
      {
        'identifier': 'ara-muyassar',
        'name': 'Al-Muyassar',
        'language': 'Arabic',
      },
      {'identifier': 'ara-tanweer', 'name': 'At-Tanweer', 'language': 'Arabic'},
      {'identifier': 'ara-waseet', 'name': 'Al-Waseet', 'language': 'Arabic'},
      {
        'identifier': 'eng-safiurrahmanalm',
        'name': 'Tafsir Ibn Kathir (English)',
        'language': 'English',
      },
    ];
    return tafsirEditions
        .map(
          (t) => QuranEdition(
            identifier: t['identifier'],
            name: t['name'],
            englishName: t['name'],
            language: t['language'],
            format: 'text',
            type: 'tafsir',
          ),
        )
        .toList();
  }

  Future<String?> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    String edition = 'ar.jalalayn',
  }) async {
    // Try offline first for Jalalayn
    if (edition == 'ar.jalalayn') {
      try {
        final offlineData = await _offlineQuran.getAyahTafsir(
          surahNumber,
          ayahNumber,
          edition: edition,
        );
        if (offlineData != null) return offlineData;
      } catch (e) {
        debugPrint('Offline tafsir not available, fetching online: $e');
      }
    }

    // Fetch from CDN - get the whole chapter and extract the verse
    try {
      final resolvedEdition = _resolveEdition(edition);
      final response = await _dio.get(
        '$_quranCdnApi/editions/$resolvedEdition/$surahNumber.min.json',
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> verses = data['chapter'] ?? [];
        for (final v in verses) {
          if (v['verse'] == ayahNumber) {
            return v['text'] as String?;
          }
        }
      }
    } catch (e) {
      debugPrint('CDN Error (getAyahTafsir): $e');
    }

    // Ultimate fallback to old API
    try {
      final response = await _dio.get(
        '$_alQuranApi/ayah/$surahNumber:$ayahNumber/$edition',
      );
      if (response.statusCode == 200) {
        return response.data['data']['text'];
      }
    } catch (e) {
      debugPrint('Legacy API Error (getAyahTafsir): $e');
    }
    return null;
  }

  // --- Hadith Service ---
  Future<List<HadithBook>> getHadithBooks() async {
    try {
      final response = await _dio.get('$_hadithCdnApi/editions.json');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<HadithBook> books = [];

        data.forEach((key, value) {
          final collection = value['collection'] as List;
          final arabicEdition = collection.firstWhere(
            (e) => e['language'] == 'Arabic',
            orElse: () => collection.first,
          );

          books.add(
            HadithBook(
              id: arabicEdition['name'], // e.g. ara-bukhari
              name: value['name'],
              nameAr: _getArabicBookName(key),
              available: _getHadithCount(key),
            ),
          );
        });

        return books;
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getHadithBooks): $e');
      // Fallback
      return _getLegacyHadithBooks();
    }
  }

  int _getHadithCount(String key) {
    switch (key) {
      case 'bukhari':
        return 7563;
      case 'muslim':
        return 7459;
      case 'abudawud':
        return 5274;
      case 'tirmidhi':
        return 3956;
      case 'nasai':
        return 5758;
      case 'ibnmajah':
        return 4341;
      case 'malik':
        return 1849;
      case 'ahmad':
        return 26363;
      default:
        return 1; // At least show it as available if it's in the list
    }
  }

  String _getArabicBookName(String key) {
    if (_hadithBookMap.containsKey(key)) {
      switch (key) {
        case 'bukhari':
          return 'صحيح البخاري';
        case 'muslim':
          return 'صحيح مسلم';
        case 'abudawud':
          return 'سنن أبي داود';
        case 'tirmidhi':
          return 'جامع الترمذي';
        case 'nasai':
          return 'سنن النسائي';
        case 'ibnmajah':
          return 'سنن ابن ماجه';
        case 'malik':
          return 'موطأ مالك';
        case 'ahmad':
          return 'مسند أحمد';
        case 'darimi':
          return 'سنن الدارمي';
      }
    }
    return key;
  }

  Future<List<HadithBook>> _getLegacyHadithBooks() async {
    try {
      final response = await _dio.get('$_hadithApiLegacy/books');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => HadithBook.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<HadithModel>> getHadiths(
    String editionName, {
    int? sectionNumber,
  }) async {
    try {
      final url = sectionNumber != null
          ? '$_hadithCdnApi/editions/$editionName/sections/$sectionNumber.min.json'
          : '$_hadithCdnApi/editions/$editionName.min.json';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> hadithsJson = response.data['hadiths'];
        final metadata = response.data['metadata'];
        final bookName = metadata['name'];

        return hadithsJson.map((json) {
          // Fawaz Ahmed's API structure to HadithModel mapping
          final map = Map<String, dynamic>.from(json);
          map['arab'] = map['text'];
          map['book'] = bookName;

          // Grades handle
          if (map['grades'] != null && (map['grades'] as List).isNotEmpty) {
            map['grade'] = (map['grades'] as List).first['grade'];
          }

          return HadithModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getHadiths): $e');
      return [];
    }
  }

  // --- Adhkar Service ---
  // Using the same endpoint as React project for Adhkar
  Future<Map<String, List<AdhkarModel>>> getAzkar() async {
    try {
      final response = await _dio.get(
        'https://quran.yousefheiba.com/api/azkar',
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return data.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((i) => AdhkarModel.fromJson(i)).toList(),
          ),
        );
      }
      return {};
    } catch (e) {
      debugPrint('API Error (getAzkar): $e');
      return {};
    }
  }

  Future<Map<String, List<AdhkarModel>>> getDuas() async {
    try {
      final response = await _dio.get('https://quran.yousefheiba.com/api/duas');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return data.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((i) => AdhkarModel.fromJson(i)).toList(),
          ),
        );
      }
      return {};
    } catch (e) {
      debugPrint('API Error (getDuas): $e');
      return {};
    }
  }

  // --- Video Service ---
  Future<List<VideoModel>> getVideos() async {
    try {
      // Load local videos from JSON
      final String jsonString = await rootBundle.loadString(
        'assets/data/videos.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<VideoModel> localVideos = jsonList
          .map((json) => VideoModel.fromJson(json))
          .toList();

      // Try fetching API videos
      final response = await _dio.get('$_recitersApi/videos?language=ar');
      if (response.statusCode == 200) {
        final List<dynamic> apiData = response.data['videos'];
        final List<VideoModel> apiVideos = apiData
            .map((json) => VideoModel.fromJson(json))
            .toList();
        return [...localVideos, ...apiVideos];
      }
      return localVideos;
    } catch (e) {
      debugPrint('Error in getVideos: $e');
      // If JSON fails, it's a critical error for the library display
      return [];
    }
  }

  Future<List<VideoType>> getVideoTypes() async {
    final biographyType = VideoType(id: 99, name: "السيرة النبوية");

    try {
      final response = await _dio.get('$_recitersApi/video_types?language=ar');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['video_types'];
        final List<VideoType> apiTypes = data
            .map((json) => VideoType.fromJson(json))
            .toList();
        return [biographyType, ...apiTypes];
      }
      return [biographyType];
    } catch (e) {
      debugPrint('API Error (getVideoTypes): $e');
      return [biographyType];
    }
  }

  // --- IslamHouse Library ---
  Future<List<BookModel>> getLibraryItems({
    String type = 'books',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_islamHouseApi/$type/ar/ar/$page/$limit/json',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('API Error (getLibraryItems): $e');
      return [];
    }
  }

  // --- Search Utility ---
  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    if (query.isEmpty) return {'reciters': [], 'surahs': []};

    final results = await Future.wait([getReciters(), getSurahs()]);

    final List<Reciter> allReciters = results[0] as List<Reciter>;
    final List<Surah> allSurahs = results[1] as List<Surah>;

    final filteredReciters = allReciters
        .where((r) => r.name?.contains(query) ?? false)
        .take(10)
        .toList();

    final filteredSurahs = allSurahs
        .where(
          (s) =>
              (s.name?.contains(query) ?? false) ||
              (s.englishName?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .take(10)
        .toList();

    return {'reciters': filteredReciters, 'surahs': filteredSurahs};
  }
}
