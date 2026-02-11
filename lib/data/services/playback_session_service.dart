import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:islamic_library_flutter/data/models/playback_session.dart';

/// Service for persisting and restoring playback sessions
/// Requirements 5.4: Session restoration functionality
class PlaybackSessionService {
  static const String _boxName = 'playback_session';
  static const String _sessionKey = 'current_session';

  /// Initialize the service by opening the Hive box
  static Future<void> initialize() async {
    try {
      await Hive.openBox(_boxName);
      debugPrint('📦 PlaybackSessionService: Initialized successfully');
    } catch (e) {
      debugPrint('📦 PlaybackSessionService: Initialization error: $e');
      rethrow;
    }
  }

  /// Save the current playback session
  /// Requirements 5.4: Support saving current position and playlist
  static Future<void> saveSession(PlaybackSession session) async {
    try {
      final box = Hive.box(_boxName);
      final json = session.toJson();
      final jsonString = jsonEncode(json);

      await box.put(_sessionKey, jsonString);
      debugPrint(
        '📦 PlaybackSessionService: Session saved - '
        'playlist: ${session.playlist.length} items, '
        'index: ${session.currentIndex}, '
        'position: ${session.currentPosition}',
      );
    } catch (e) {
      debugPrint('📦 PlaybackSessionService: Error saving session: $e');
      rethrow;
    }
  }

  /// Restore the previously saved playback session
  /// Requirements 5.4: Support restoring saved session
  static Future<PlaybackSession?> restoreSession() async {
    try {
      final box = Hive.box(_boxName);
      final jsonString = box.get(_sessionKey) as String?;

      if (jsonString == null) {
        debugPrint('📦 PlaybackSessionService: No saved session found');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = PlaybackSession.fromJson(json);

      debugPrint(
        '📦 PlaybackSessionService: Session restored - '
        'playlist: ${session.playlist.length} items, '
        'index: ${session.currentIndex}, '
        'position: ${session.currentPosition}',
      );

      return session;
    } catch (e) {
      debugPrint('📦 PlaybackSessionService: Error restoring session: $e');
      // Return null instead of rethrowing to allow app to continue
      return null;
    }
  }

  /// Clear the saved session
  /// Requirements 5.4: Clean up saved state when no longer needed
  static Future<void> clearSession() async {
    try {
      final box = Hive.box(_boxName);
      await box.delete(_sessionKey);
      debugPrint('📦 PlaybackSessionService: Session cleared');
    } catch (e) {
      debugPrint('📦 PlaybackSessionService: Error clearing session: $e');
      rethrow;
    }
  }

  /// Check if a saved session exists
  static Future<bool> hasSession() async {
    try {
      final box = Hive.box(_boxName);
      return box.containsKey(_sessionKey);
    } catch (e) {
      debugPrint('📦 PlaybackSessionService: Error checking session: $e');
      return false;
    }
  }

  /// Dispose of the service and close the Hive box
  static Future<void> dispose() async {
    try {
      await Hive.box(_boxName).close();
      debugPrint('📦 PlaybackSessionService: Disposed successfully');
    } catch (e) {
      debugPrint('📦 PlaybackSessionService: Error disposing: $e');
    }
  }
}
