import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';

class LocalHadithService {
  // Cache for loaded hadiths
  Map<String, List<HadithModel>>? _hadithCache;

  /// Load all Hadiths from local JSON files
  Future<Map<String, List<HadithModel>>> loadAllHadiths() async {
    if (_hadithCache != null) return _hadithCache!;

    try {
      _hadithCache = {};

      // Load Bukhari
      final bukhariHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/bukhari.json',
        'Sahih al-Bukhari',
      );
      _hadithCache!['bukhari'] = bukhariHadiths;

      // Load Muslim
      final muslimHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/muslim.json',
        'Sahih Muslim',
      );
      _hadithCache!['muslim'] = muslimHadiths;

      // Load Abu Dawud
      final abudawudHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/abudawud.json',
        'Sunan Abu Dawud',
      );
      _hadithCache!['abudawud'] = abudawudHadiths;

      // Load Tirmidhi
      final tirmidhiHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/tirmidhi.json',
        "Jami' at-Tirmidhi",
      );
      _hadithCache!['tirmidhi'] = tirmidhiHadiths;

      // Load Nasa'i
      final nasaiHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/nasai.json',
        "Sunan an-Nasa'i",
      );
      _hadithCache!['nasai'] = nasaiHadiths;

      // Load Ibn Majah
      final ibnmajahHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/ibnmajah.json',
        'Sunan Ibn Majah',
      );
      _hadithCache!['ibnmajah'] = ibnmajahHadiths;

      // Load Malik
      final malikHadiths = await _loadHadithsFromFile(
        'assets/data/hadith/malik.json',
        'Muwatta Malik',
      );
      _hadithCache!['malik'] = malikHadiths;

      // Load Nawawi
      final nawawiHadiths = await _loadHadithsFromFile(
        'assets/data/nawawi/nawawi.json',
        "An-Nawawi's Forty",
      );
      _hadithCache!['nawawi'] = nawawiHadiths;

      return _hadithCache!;
    } catch (e) {
      debugPrint('Error loading Hadiths: $e');
      return {};
    }
  }

  /// Load Hadiths from a specific file
  Future<List<HadithModel>> _loadHadithsFromFile(
    String path,
    String bookName,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      debugPrint('Loaded $path: ${jsonString.length} chars');
      final jsonData = json.decode(jsonString);

      List<HadithModel> hadiths = [];

      if (jsonData is List) {
        hadiths = jsonData.map((item) {
          final hadithMap = Map<String, dynamic>.from(item as Map);
          hadithMap['book'] = bookName;
          return HadithModel.fromJson(_normalizeHadithMap(hadithMap));
        }).toList();
      } else if (jsonData is Map && jsonData.containsKey('hadiths')) {
        hadiths = (jsonData['hadiths'] as List).map((item) {
          final hadithMap = Map<String, dynamic>.from(item as Map);
          hadithMap['book'] = bookName;
          return HadithModel.fromJson(_normalizeHadithMap(hadithMap));
        }).toList();
      }

      debugPrint('Parsed ${hadiths.length} hadiths from $path');

      return hadiths;
    } catch (e) {
      debugPrint('Error loading from $path: $e');
      return [];
    }
  }

  /// Normalize Hadith Map to match HadithModel keys
  Map<String, dynamic> _normalizeHadithMap(Map<String, dynamic> map) {
    // Map 'arabic' to 'text' (which is then mapped to 'arab' in HadithModel)
    if (map.containsKey('arabic') && !map.containsKey('text')) {
      map['text'] = map['arabic'];
    }

    // Map 'idInBook' to 'hadithnumber'
    if (map.containsKey('idInBook') && !map.containsKey('hadithnumber')) {
      map['hadithnumber'] = map['idInBook'];
    }

    // Map complex 'english' object to flat fields
    if (map['english'] is Map) {
      final englishMap = map['english'] as Map<String, dynamic>;
      map['narrator'] = englishMap['narrator'];
      map['english'] = englishMap['text'];
    }

    return map;
  }

  /// Get Hadiths by book
  Future<List<HadithModel>> getHadithsByBook(String bookKey) async {
    final allHadiths = await loadAllHadiths();
    return allHadiths[bookKey] ?? [];
  }

  /// Get all available books
  Future<List<String>> getAvailableBooks() async {
    final allHadiths = await loadAllHadiths();
    return allHadiths.keys.toList();
  }

  /// Search Hadiths
  Future<List<HadithModel>> searchHadiths(String query) async {
    final allHadiths = await loadAllHadiths();
    final results = <HadithModel>[];

    allHadiths.forEach((book, hadiths) {
      results.addAll(
        hadiths.where(
          (hadith) =>
              hadith.arab?.contains(query) == true ||
              hadith.english?.contains(query) == true ||
              hadith.chapter?.contains(query) == true,
        ),
      );
    });

    return results;
  }

  /// Get random Hadith (for daily hadith widget)
  Future<HadithModel?> getRandomHadith() async {
    final allHadiths = await loadAllHadiths();
    if (allHadiths.isEmpty) return null;

    final allHadithsList = <HadithModel>[];
    allHadiths.forEach((book, hadiths) => allHadithsList.addAll(hadiths));

    if (allHadithsList.isEmpty) return null;

    final randomIndex = DateTime.now().day % allHadithsList.length;
    return allHadithsList[randomIndex];
  }

  /// Get all available books as HadithBook objects
  Future<List<HadithBook>> getLocalBooks() async {
    return [
      // Currently available with local data
      HadithBook(
        id: 'bukhari',
        name: 'Sahih al-Bukhari',
        nameAr: 'صحيح البخاري',
        available: 7563,
        totalHadiths: 7563,
      ),
      HadithBook(
        id: 'muslim',
        name: 'Sahih Muslim',
        nameAr: 'صحيح مسلم',
        available: 7459,
        totalHadiths: 7459,
      ),
      HadithBook(
        id: 'abudawud',
        name: 'Sunan Abu Dawud',
        nameAr: 'سنن أبي داود',
        available: 5274,
        totalHadiths: 5274,
      ),
      HadithBook(
        id: 'tirmidhi',
        name: "Jami' at-Tirmidhi",
        nameAr: 'جامع الترمذي',
        available: 3956,
        totalHadiths: 3956,
      ),
      HadithBook(
        id: 'nasai',
        name: "Sunan an-Nasa'i",
        nameAr: 'سنن النسائي',
        available: 5758,
        totalHadiths: 5758,
      ),
      HadithBook(
        id: 'ibnmajah',
        name: 'Sunan Ibn Majah',
        nameAr: 'سنن ابن ماجه',
        available: 4341,
        totalHadiths: 4341,
      ),
      HadithBook(
        id: 'malik',
        name: 'Muwatta Malik',
        nameAr: 'موطأ مالك',
        available: 1849,
        totalHadiths: 1849,
      ),
      HadithBook(
        id: 'nawawi',
        name: "An-Nawawi's Forty",
        nameAr: 'الأربعون النووية',
        available: 42,
        totalHadiths: 42,
      ),
    ];
  }
}
