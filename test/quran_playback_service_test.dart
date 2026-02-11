import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_library_flutter/data/models/playback_session.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:audio_service/audio_service.dart';

/// Feature: quran-notification-player
/// Property 7: استعادة الجلسة عند بدء التطبيق
/// Validates: Requirements 5.4
///
/// This test verifies that PlaybackSession can be properly serialized and
/// deserialized, which is the foundation for session restoration functionality.
void main() {
  group('PlaybackSession Serialization Tests', () {
    test('PlaybackSession can be serialized and deserialized correctly', () {
      // Create a sample playback session
      final originalSession = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(seconds: 5),
            translation:
                'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          ),
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 2,
            arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
            audioUrl: 'https://example.com/001002.mp3',
            duration: Duration(seconds: 4),
            translation: 'All praise is due to Allah, Lord of the worlds.',
          ),
        ],
        currentIndex: 1,
        currentPosition: Duration(seconds: 2),
        isPlaying: true,
        repeatMode: AudioServiceRepeatMode.all,
        shuffleMode: AudioServiceShuffleMode.none,
      );

      // Serialize to JSON
      final json = originalSession.toJson();

      // Deserialize from JSON
      final restoredSession = PlaybackSession.fromJson(json);

      // Verify all fields are correctly restored
      expect(
        restoredSession.playlist.length,
        equals(originalSession.playlist.length),
      );
      expect(
        restoredSession.currentIndex,
        equals(originalSession.currentIndex),
      );
      expect(
        restoredSession.currentPosition,
        equals(originalSession.currentPosition),
      );
      expect(restoredSession.isPlaying, equals(originalSession.isPlaying));
      expect(restoredSession.repeatMode, equals(originalSession.repeatMode));
      expect(restoredSession.shuffleMode, equals(originalSession.shuffleMode));

      // Verify playlist items
      for (var i = 0; i < originalSession.playlist.length; i++) {
        final original = originalSession.playlist[i];
        final restored = restoredSession.playlist[i];

        expect(restored.surahNumber, equals(original.surahNumber));
        expect(restored.surahName, equals(original.surahName));
        expect(restored.verseNumber, equals(original.verseNumber));
        expect(restored.arabicText, equals(original.arabicText));
        expect(restored.audioUrl, equals(original.audioUrl));
        expect(restored.duration, equals(original.duration));
        expect(restored.translation, equals(original.translation));
      }
    });

    test('PlaybackSession handles empty playlist correctly', () {
      final session = PlaybackSession(
        playlist: [],
        currentIndex: 0,
        currentPosition: Duration.zero,
        isPlaying: false,
      );

      final json = session.toJson();
      final restored = PlaybackSession.fromJson(json);

      expect(restored.playlist, isEmpty);
      expect(restored.currentIndex, equals(0));
      expect(restored.currentPosition, equals(Duration.zero));
      expect(restored.isPlaying, isFalse);
    });

    test('PlaybackSession handles different repeat modes correctly', () {
      for (final mode in AudioServiceRepeatMode.values) {
        final session = PlaybackSession(
          playlist: [
            const QuranVerse(
              surahNumber: 1,
              surahName: 'الفاتحة',
              verseNumber: 1,
              arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              audioUrl: 'https://example.com/001001.mp3',
              duration: Duration(seconds: 5),
            ),
          ],
          currentIndex: 0,
          currentPosition: Duration.zero,
          isPlaying: false,
          repeatMode: mode,
        );

        final json = session.toJson();
        final restored = PlaybackSession.fromJson(json);

        expect(
          restored.repeatMode,
          equals(mode),
          reason: 'Repeat mode $mode should be preserved',
        );
      }
    });

    test('PlaybackSession handles different shuffle modes correctly', () {
      for (final mode in AudioServiceShuffleMode.values) {
        final session = PlaybackSession(
          playlist: [
            const QuranVerse(
              surahNumber: 1,
              surahName: 'الفاتحة',
              verseNumber: 1,
              arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              audioUrl: 'https://example.com/001001.mp3',
              duration: Duration(seconds: 5),
            ),
          ],
          currentIndex: 0,
          currentPosition: Duration.zero,
          isPlaying: false,
          shuffleMode: mode,
        );

        final json = session.toJson();
        final restored = PlaybackSession.fromJson(json);

        expect(
          restored.shuffleMode,
          equals(mode),
          reason: 'Shuffle mode $mode should be preserved',
        );
      }
    });

    test('PlaybackSession copyWith creates correct copies', () {
      final original = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(seconds: 5),
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration(seconds: 2),
        isPlaying: true,
      );

      // Test updating individual fields
      final withNewIndex = original.copyWith(currentIndex: 1);
      expect(withNewIndex.currentIndex, equals(1));
      expect(withNewIndex.currentPosition, equals(original.currentPosition));
      expect(withNewIndex.isPlaying, equals(original.isPlaying));

      final withNewPosition = original.copyWith(
        currentPosition: Duration(seconds: 5),
      );
      expect(withNewPosition.currentPosition, equals(Duration(seconds: 5)));
      expect(withNewPosition.currentIndex, equals(original.currentIndex));

      final withNewPlayingState = original.copyWith(isPlaying: false);
      expect(withNewPlayingState.isPlaying, isFalse);
      expect(withNewPlayingState.currentIndex, equals(original.currentIndex));
    });

    test('PlaybackSession handles verses without translation', () {
      final session = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(seconds: 5),
            translation: null, // No translation
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration.zero,
        isPlaying: false,
      );

      final json = session.toJson();
      final restored = PlaybackSession.fromJson(json);

      expect(restored.playlist[0].translation, isNull);
    });

    test('PlaybackSession handles large playlists correctly', () {
      // Create a large playlist (e.g., entire surah)
      final largePlaylist = List.generate(
        286, // Al-Baqarah has 286 verses
        (index) => QuranVerse(
          surahNumber: 2,
          surahName: 'البقرة',
          verseNumber: index + 1,
          arabicText: 'آية ${index + 1}',
          audioUrl:
              'https://example.com/002${(index + 1).toString().padLeft(3, '0')}.mp3',
          duration: Duration(seconds: 5 + index % 10),
        ),
      );

      final session = PlaybackSession(
        playlist: largePlaylist,
        currentIndex: 150,
        currentPosition: Duration(seconds: 30),
        isPlaying: true,
      );

      final json = session.toJson();
      final restored = PlaybackSession.fromJson(json);

      expect(restored.playlist.length, equals(286));
      expect(restored.currentIndex, equals(150));
      expect(restored.playlist[150].verseNumber, equals(151));
    });

    test('PlaybackSession handles maximum duration values', () {
      final session = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(hours: 1), // Long duration
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration(minutes: 30),
        isPlaying: false,
      );

      final json = session.toJson();
      final restored = PlaybackSession.fromJson(json);

      expect(restored.playlist[0].duration, equals(Duration(hours: 1)));
      expect(restored.currentPosition, equals(Duration(minutes: 30)));
    });
  });
}
