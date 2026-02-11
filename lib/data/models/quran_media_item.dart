import 'package:audio_service/audio_service.dart';

/// Represents a Quran verse with all necessary information for audio playback
/// Requirements 1.1, 3.1, 3.2: Proper Arabic text support in notifications
class QuranVerse {
  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final String arabicText;
  final String audioUrl;
  final Duration duration;
  final String? translation;

  const QuranVerse({
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.arabicText,
    required this.audioUrl,
    required this.duration,
    this.translation,
  });

  /// Converts QuranVerse to MediaItem for AudioService
  /// Requirements 1.1, 3.1, 3.2: Format with proper Arabic text for notifications
  MediaItem toMediaItem() {
    return MediaItem(
      id: audioUrl,
      // Title format: "الفاتحة - آية 1"
      title: '$surahName - آية $verseNumber',
      // Artist: "القرآن الكريم"
      artist: 'القرآن الكريم',
      // Album format: "سورة الفاتحة"
      album: 'سورة $surahName',
      duration: duration,
      artUri: null, // Can be set to Quran artwork if available
      extras: {
        'surahNumber': surahNumber,
        'verseNumber': verseNumber,
        'surahName': surahName,
        'arabicText': arabicText,
        'translation': translation,
      },
    );
  }

  /// Creates QuranVerse from MediaItem
  static QuranVerse fromMediaItem(MediaItem item) {
    final extras = item.extras ?? {};
    return QuranVerse(
      surahNumber: extras['surahNumber'] as int,
      surahName: extras['surahName'] as String,
      verseNumber: extras['verseNumber'] as int,
      arabicText: extras['arabicText'] as String,
      audioUrl: item.id,
      duration: item.duration ?? Duration.zero,
      translation: extras['translation'] as String?,
    );
  }
}

/// Enhanced MediaItem wrapper for Quran content
/// Requirements 1.1, 3.1, 3.2: Proper Arabic text support in notifications
class QuranMediaItem {
  final String surahName;
  final int surahNumber;
  final int verseNumber;
  final String audioUrl;
  final Duration duration;
  final String? artworkUrl;

  const QuranMediaItem({
    required this.surahName,
    required this.surahNumber,
    required this.verseNumber,
    required this.audioUrl,
    required this.duration,
    this.artworkUrl,
  });

  /// Converts to MediaItem with proper Arabic text formatting
  /// Requirements 1.1, 3.1, 3.2: Format notification text for Arabic display
  MediaItem toMediaItem() {
    return MediaItem(
      id: audioUrl,
      // Title format: "الفاتحة - آية 1"
      title: '$surahName - آية $verseNumber',
      // Artist: "القرآن الكريم"
      artist: 'القرآن الكريم',
      // Album format: "سورة الفاتحة"
      album: 'سورة $surahName',
      duration: duration,
      artUri: artworkUrl != null ? Uri.parse(artworkUrl!) : null,
      extras: {
        'surahNumber': surahNumber,
        'verseNumber': verseNumber,
        'surahName': surahName,
      },
    );
  }
}
