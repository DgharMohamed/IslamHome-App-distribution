import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Generic caching layer built on Hive for offline support.
/// Stores API responses with optional TTL (time-to-live).
class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  static const String _boxName = 'offline_cache';
  static const String _metaBoxName = 'offline_cache_meta';

  Box? _box;
  Box? _metaBox;

  /// Initialize Hive boxes. Must be called before using the service.
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _metaBox = await Hive.openBox(_metaBoxName);
    debugPrint('💾 OfflineCacheService initialized');
  }

  /// Save data to cache with an optional TTL.
  /// [key] — unique identifier (e.g., 'reciters', 'radios')
  /// [data] — JSON-serializable data (List or Map)
  /// [ttl] — how long the cache remains valid (default: 24 hours)
  Future<void> saveToCache(
    String key,
    dynamic data, {
    Duration ttl = const Duration(hours: 24),
  }) async {
    try {
      final jsonString = json.encode(data);
      await _box?.put(key, jsonString);
      await _metaBox?.put(
        '${key}_expiry',
        DateTime.now().add(ttl).toIso8601String(),
      );
      debugPrint('💾 Cached: $key (TTL: ${ttl.inHours}h)');
    } catch (e) {
      debugPrint('❌ Cache save error ($key): $e');
    }
  }

  /// Retrieve cached data. Returns null if not found or expired.
  dynamic getFromCache(String key) {
    try {
      if (!isCacheValid(key)) return null;

      final jsonString = _box?.get(key) as String?;
      if (jsonString == null) return null;

      return json.decode(jsonString);
    } catch (e) {
      debugPrint('❌ Cache read error ($key): $e');
      return null;
    }
  }

  /// Check if a cached entry exists and hasn't expired.
  bool isCacheValid(String key) {
    try {
      final expiryStr = _metaBox?.get('${key}_expiry') as String?;
      if (expiryStr == null) return false;

      final expiry = DateTime.parse(expiryStr);
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }

  /// Check if there is any cached data (even if expired).
  bool hasCache(String key) {
    return _box?.containsKey(key) ?? false;
  }

  /// Get cached data even if expired (for offline fallback).
  dynamic getFromCacheForce(String key) {
    try {
      final jsonString = _box?.get(key) as String?;
      if (jsonString == null) return null;
      return json.decode(jsonString);
    } catch (e) {
      debugPrint('❌ Cache force-read error ($key): $e');
      return null;
    }
  }

  /// Clear all cached data.
  Future<void> clearCache() async {
    await _box?.clear();
    await _metaBox?.clear();
    debugPrint('🗑️ Cache cleared');
  }

  /// Clear a specific cache entry.
  Future<void> clearKey(String key) async {
    await _box?.delete(key);
    await _metaBox?.delete('${key}_expiry');
  }
}
