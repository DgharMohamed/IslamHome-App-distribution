import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_library_flutter/data/models/adhkar_model.dart';

class LocalAdhkarService {
  // Cache for loaded adhkar
  Map<String, List<AdhkarModel>>? _adhkarCache;

  /// Load all Adhkar from local JSON files
  Future<Map<String, List<AdhkarModel>>> loadAllAdhkar() async {
    if (_adhkarCache != null) return _adhkarCache!;

    try {
      _adhkarCache = {};

      // Load from rn0x source
      debugPrint('📖 Loading adhkar_rn0x.json...');
      final rn0xData = await _loadAdhkarFromFile(
        'assets/data/adhkar/adhkar_rn0x.json',
      );
      debugPrint('✅ Loaded ${rn0xData.length} categories from rn0x');

      // Load from osamayy source
      debugPrint('📖 Loading azkar_db.json...');
      final osamayyData = await _loadAdhkarFromFile(
        'assets/data/adhkar/azkar_db.json',
      );
      debugPrint('✅ Loaded ${osamayyData.length} categories from azkar_db');

      // Merge both sources
      _adhkarCache = _mergeAdhkarSources(rn0xData, osamayyData);
      debugPrint('✅ Total categories after merge: ${_adhkarCache!.length}');
      debugPrint('📋 Categories: ${_adhkarCache!.keys.join(", ")}');

      return _adhkarCache!;
    } catch (e) {
      debugPrint('❌ Error loading Adhkar: $e');
      return {};
    }
  }

  /// Load Adhkar from a specific file
  Future<Map<String, List<AdhkarModel>>> _loadAdhkarFromFile(
    String path,
  ) async {
    try {
      debugPrint('📂 Attempting to load: $path');
      final jsonString = await rootBundle.loadString(path);
      debugPrint('✅ File loaded successfully, length: ${jsonString.length}');

      final jsonData = json.decode(jsonString);
      debugPrint('✅ JSON decoded successfully');

      // Parse based on structure (will need to adjust based on actual JSON format)
      Map<String, List<AdhkarModel>> adhkarMap = {};

      if (jsonData is List) {
        // If it's a flat list
        debugPrint('📋 Processing as flat list');
        adhkarMap['general'] = jsonData
            .map((item) => AdhkarModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (jsonData is Map) {
        // If it's categorized
        debugPrint(
          '📋 Processing as categorized map with ${jsonData.keys.length} categories',
        );
        jsonData.forEach((key, value) {
          if (value is List) {
            try {
              debugPrint(
                '  ➡️ Processing category: $key (${value.length} items)',
              );
              adhkarMap[key] = value
                  .map(
                    (item) =>
                        AdhkarModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
              debugPrint('  ✅ Category $key loaded successfully');
            } catch (e) {
              debugPrint('  ❌ Error in category $key: $e');
            }
          }
        });
      }

      debugPrint('✅ Loaded ${adhkarMap.length} categories from $path');
      return adhkarMap;
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading from $path: $e');
      debugPrint('Stack trace: $stackTrace');
      return {};
    }
  }

  /// Merge multiple Adhkar sources
  Map<String, List<AdhkarModel>> _mergeAdhkarSources(
    Map<String, List<AdhkarModel>> source1,
    Map<String, List<AdhkarModel>> source2,
  ) {
    final merged = Map<String, List<AdhkarModel>>.from(source1);

    source2.forEach((category, adhkar) {
      if (merged.containsKey(category)) {
        merged[category]!.addAll(adhkar);
      } else {
        merged[category] = adhkar;
      }
    });

    return merged;
  }

  /// Get Adhkar by category
  Future<List<AdhkarModel>> getAdhkarByCategory(String category) async {
    final allAdhkar = await loadAllAdhkar();
    return allAdhkar[category] ?? [];
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    final allAdhkar = await loadAllAdhkar();
    return allAdhkar.keys.toList();
  }

  /// Search Adhkar
  Future<List<AdhkarModel>> searchAdhkar(String query) async {
    final allAdhkar = await loadAllAdhkar();
    final results = <AdhkarModel>[];

    allAdhkar.forEach((category, adhkar) {
      results.addAll(
        adhkar.where(
          (dhikr) =>
              dhikr.zekrText.contains(query) == true ||
              dhikr.description?.contains(query) == true,
        ),
      );
    });

    return results;
  }

  /// Get local Azkar (category-wise) - Returns ALL categories including duas
  Future<Map<String, List<AdhkarModel>>> getLocalAzkar() async {
    final all = await loadAllAdhkar();
    // Return all categories (azkar + duas merged)
    return all;
  }

  /// Get local Duas
  Future<Map<String, List<AdhkarModel>>> getLocalDuas() async {
    final all = await loadAllAdhkar();
    // Filter only duas categories
    final duasCategories = {'prophetic_duas', 'quran_duas', 'prophets_duas'};

    return Map.fromEntries(
      all.entries.where((entry) => duasCategories.contains(entry.key)),
    );
  }
}
