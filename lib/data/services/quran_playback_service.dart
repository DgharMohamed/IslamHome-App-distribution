import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_library_flutter/data/services/quran_audio_handler.dart';

/// Service wrapper for initializing and managing Quran playback
class QuranPlaybackService {
  static QuranAudioHandler? _audioHandler;

  /// Initialize the Quran playback service with proper Arabic notification support
  static Future<void> initialize() async {
    debugPrint('🎵 QuranPlaybackService: Initializing...');

    try {
      // Initialize AudioService with Quran-specific configuration
      // Requirements 1.1, 5.1: Proper Arabic notification support and state management
      _audioHandler = await AudioService.init(
        builder: () => QuranAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'quran_playback',
          androidNotificationChannelName: 'تشغيل القرآن الكريم',
          androidNotificationChannelDescription:
              'التحكم في تشغيل القرآن الكريم',
          androidNotificationOngoing:
              false, // Allow notification to be dismissed (Requirement 1.3)
          androidStopForegroundOnPause:
              false, // Keep notification visible when paused (Requirement 1.2, 4.1)
          androidNotificationClickStartsActivity: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidShowNotificationBadge: true,
          preloadArtwork:
              false, // Disable for better performance with streaming
          artDownscaleWidth: 200,
          artDownscaleHeight: 200,
          fastForwardInterval: Duration(seconds: 10),
          rewindInterval: Duration(seconds: 10),
        ),
      );

      debugPrint('🎵 QuranPlaybackService: Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('🎵 QuranPlaybackService: Initialization failed: $e');
      debugPrint('🎵 QuranPlaybackService: Stack trace: $stackTrace');

      // Create fallback handler
      _audioHandler = QuranAudioHandler();
      debugPrint('🎵 QuranPlaybackService: Created fallback handler');
    }
  }

  /// Get the audio handler instance
  static QuranAudioHandler get audioHandler {
    if (_audioHandler == null) {
      throw StateError(
        'QuranPlaybackService not initialized. Call initialize() first.',
      );
    }
    return _audioHandler!;
  }

  /// Check if the service is initialized
  static bool get isInitialized => _audioHandler != null;

  /// Dispose of the service and clean up resources
  static Future<void> dispose() async {
    debugPrint('🎵 QuranPlaybackService: Disposing...');
    if (_audioHandler != null) {
      await _audioHandler!.dispose();
      _audioHandler = null;
    }
  }
}
