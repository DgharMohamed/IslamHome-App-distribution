import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_library_flutter/data/models/nawawi_hadith_model.dart';

class NawawiHadithService {
  // Cache for loaded hadiths
  List<NawawiHadith>? _hadithsCache;

  /// Load all 40 Hadiths Nawawi
  Future<List<NawawiHadith>> loadAll40Hadiths() async {
    if (_hadithsCache != null) return _hadithsCache!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/nawawi/hadiths.json',
      );
      final jsonData = json.decode(jsonString);

      if (jsonData is List) {
        _hadithsCache = jsonData
            .map((item) => NawawiHadith.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (jsonData is Map && jsonData.containsKey('hadiths')) {
        _hadithsCache = (jsonData['hadiths'] as List)
            .map((item) => NawawiHadith.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return _hadithsCache ?? [];
    } catch (e) {
      debugPrint('Error loading 40 Hadith Nawawi: $e');
      return [];
    }
  }

  /// Get Hadith by number (1-40)
  Future<NawawiHadith?> getHadithByNumber(int number) async {
    final hadiths = await loadAll40Hadiths();
    try {
      return hadiths.firstWhere((h) => h.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Get daily Hadith (rotates through the 40)
  Future<NawawiHadith?> getDailyHadith() async {
    final hadiths = await loadAll40Hadiths();
    if (hadiths.isEmpty) return null;

    // Use day of year to rotate through hadiths
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;

    final index = dayOfYear % hadiths.length;
    return hadiths[index];
  }

  /// Get hadiths by theme
  Future<List<NawawiHadith>> getHadithsByTheme(String theme) async {
    final hadiths = await loadAll40Hadiths();
    return hadiths.where((h) => h.theme?.contains(theme) == true).toList();
  }
}
