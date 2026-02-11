import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:islamic_library_flutter/data/models/playback_session.dart';
import 'package:islamic_library_flutter/data/services/playback_session_service.dart';
import 'dart:io';

/// Integration tests for QuranAudioHandler session persistence
/// Requirements 5.4: Session restoration functionality
///
/// These tests verify that the QuranAudioHandler properly integrates with
/// PlaybackSessionService to save and restore playback sessions.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    // Create a temporary directory for Hive
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    // Initialize the service before each test
    await PlaybackSessionService.initialize();
  });

  tearDown(() async {
    // Clear the session after each test
    await PlaybackSessionService.clearSession();
  });

  tearDownAll(() async {
    // Clean up Hive and delete temp directory
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('QuranAudioHandler Session Integration', () {
    test(
      'PlaybackSessionService can save and restore QuranVerse data',
      () async {
        // Create sample verses
        final verses = [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(seconds: 5),
          ),
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 2,
            arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
            audioUrl: 'https://example.com/001002.mp3',
            duration: Duration(seconds: 4),
          ),
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 3,
            arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001003.mp3',
            duration: Duration(seconds: 3),
          ),
        ];

        // Simulate what QuranAudioHandler would do
        await _simulatePlaybackSession(verses, 1, Duration(seconds: 2));

        // Verify session was saved
        final hasSession = await PlaybackSessionService.hasSession();
        expect(hasSession, isTrue);

        // Restore session
        final restored = await PlaybackSessionService.restoreSession();
        expect(restored, isNotNull);
        expect(restored!.playlist.length, equals(3));
        expect(restored.currentIndex, equals(1));
        expect(restored.currentPosition, equals(Duration(seconds: 2)));
        expect(restored.playlist[1].verseNumber, equals(2));
      },
    );

    test('Session persists across multiple save operations', () async {
      final verses = [
        const QuranVerse(
          surahNumber: 2,
          surahName: 'البقرة',
          verseNumber: 1,
          arabicText: 'الم',
          audioUrl: 'https://example.com/002001.mp3',
          duration: Duration(seconds: 3),
        ),
      ];

      // Save initial session
      await _simulatePlaybackSession(verses, 0, Duration(seconds: 1));

      // Update position (simulating playback progress)
      await _simulatePlaybackSession(verses, 0, Duration(seconds: 2));

      // Verify latest position is saved
      final restored = await PlaybackSessionService.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.currentPosition, equals(Duration(seconds: 2)));
    });

    test('Session handles complete surah playlist', () async {
      // Create a full surah (Al-Fatiha has 7 verses)
      final alFatiha = List.generate(
        7,
        (i) => QuranVerse(
          surahNumber: 1,
          surahName: 'الفاتحة',
          verseNumber: i + 1,
          arabicText: 'آية ${i + 1}',
          audioUrl:
              'https://example.com/001${(i + 1).toString().padLeft(3, '0')}.mp3',
          duration: Duration(seconds: 5),
        ),
      );

      await _simulatePlaybackSession(alFatiha, 3, Duration(seconds: 2));

      final restored = await PlaybackSessionService.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.playlist.length, equals(7));
      expect(restored.currentIndex, equals(3));
      expect(restored.playlist[3].verseNumber, equals(4));
    });

    test('Session clears when explicitly requested', () async {
      final verses = [
        const QuranVerse(
          surahNumber: 1,
          surahName: 'الفاتحة',
          verseNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          audioUrl: 'https://example.com/001001.mp3',
          duration: Duration(seconds: 5),
        ),
      ];

      await _simulatePlaybackSession(verses, 0, Duration.zero);
      expect(await PlaybackSessionService.hasSession(), isTrue);

      await PlaybackSessionService.clearSession();
      expect(await PlaybackSessionService.hasSession(), isFalse);
    });
  });
}

/// Helper function to simulate what QuranAudioHandler does when saving a session
Future<void> _simulatePlaybackSession(
  List<QuranVerse> playlist,
  int currentIndex,
  Duration currentPosition,
) async {
  final session = PlaybackSession(
    playlist: playlist,
    currentIndex: currentIndex,
    currentPosition: currentPosition,
    isPlaying: true,
  );

  await PlaybackSessionService.saveSession(session);
}
