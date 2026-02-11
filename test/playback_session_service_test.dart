import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/data/models/playback_session.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:islamic_library_flutter/data/services/playback_session_service.dart';
import 'dart:io';

/// Tests for PlaybackSessionService
/// Requirements 5.4: Session persistence and restoration
///
/// These tests verify that the PlaybackSessionService can properly save and
/// restore playback sessions using Hive storage.
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

  group('PlaybackSessionService Basic Operations', () {
    test('initialize creates the Hive box', () async {
      // The box should be open after initialization
      expect(Hive.isBoxOpen('playback_session'), isTrue);
    });

    test('saveSession stores session data', () async {
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
        currentPosition: Duration(seconds: 2),
        isPlaying: true,
      );

      await PlaybackSessionService.saveSession(session);

      // Verify session was saved
      final hasSession = await PlaybackSessionService.hasSession();
      expect(hasSession, isTrue);
    });

    test('restoreSession retrieves saved session', () async {
      final originalSession = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 2,
            surahName: 'البقرة',
            verseNumber: 255,
            arabicText: 'آية الكرسي',
            audioUrl: 'https://example.com/002255.mp3',
            duration: Duration(seconds: 120),
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration(seconds: 30),
        isPlaying: false,
        repeatMode: AudioServiceRepeatMode.one,
        shuffleMode: AudioServiceShuffleMode.none,
      );

      await PlaybackSessionService.saveSession(originalSession);
      final restoredSession = await PlaybackSessionService.restoreSession();

      expect(restoredSession, isNotNull);
      expect(restoredSession!.playlist.length, equals(1));
      expect(restoredSession.playlist[0].surahNumber, equals(2));
      expect(restoredSession.playlist[0].verseNumber, equals(255));
      expect(restoredSession.currentIndex, equals(0));
      expect(restoredSession.currentPosition, equals(Duration(seconds: 30)));
      expect(restoredSession.isPlaying, isFalse);
      expect(restoredSession.repeatMode, equals(AudioServiceRepeatMode.one));
    });

    test('restoreSession returns null when no session exists', () async {
      final session = await PlaybackSessionService.restoreSession();
      expect(session, isNull);
    });

    test('clearSession removes saved session', () async {
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
      );

      await PlaybackSessionService.saveSession(session);
      expect(await PlaybackSessionService.hasSession(), isTrue);

      await PlaybackSessionService.clearSession();
      expect(await PlaybackSessionService.hasSession(), isFalse);
    });

    test('hasSession returns correct status', () async {
      expect(await PlaybackSessionService.hasSession(), isFalse);

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
      );

      await PlaybackSessionService.saveSession(session);
      expect(await PlaybackSessionService.hasSession(), isTrue);
    });
  });

  group('PlaybackSessionService Edge Cases', () {
    test('handles empty playlist', () async {
      final session = PlaybackSession(
        playlist: [],
        currentIndex: 0,
        currentPosition: Duration.zero,
        isPlaying: false,
      );

      await PlaybackSessionService.saveSession(session);
      final restored = await PlaybackSessionService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.playlist, isEmpty);
    });

    test('handles large playlist', () async {
      final largePlaylist = List.generate(
        286,
        (i) => QuranVerse(
          surahNumber: 2,
          surahName: 'البقرة',
          verseNumber: i + 1,
          arabicText: 'آية ${i + 1}',
          audioUrl:
              'https://example.com/002${(i + 1).toString().padLeft(3, '0')}.mp3',
          duration: Duration(seconds: 10),
        ),
      );

      final session = PlaybackSession(
        playlist: largePlaylist,
        currentIndex: 150,
        currentPosition: Duration(seconds: 5),
        isPlaying: true,
      );

      await PlaybackSessionService.saveSession(session);
      final restored = await PlaybackSessionService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.playlist.length, equals(286));
      expect(restored.currentIndex, equals(150));
    });

    test('handles verses with null translation', () async {
      final session = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(seconds: 5),
            translation: null,
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration.zero,
        isPlaying: false,
      );

      await PlaybackSessionService.saveSession(session);
      final restored = await PlaybackSessionService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.playlist[0].translation, isNull);
    });

    test('handles all repeat modes', () async {
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

        await PlaybackSessionService.saveSession(session);
        final restored = await PlaybackSessionService.restoreSession();

        expect(restored, isNotNull);
        expect(restored!.repeatMode, equals(mode));
      }
    });

    test('handles all shuffle modes', () async {
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

        await PlaybackSessionService.saveSession(session);
        final restored = await PlaybackSessionService.restoreSession();

        expect(restored, isNotNull);
        expect(restored!.shuffleMode, equals(mode));
      }
    });

    test('handles maximum duration values', () async {
      final session = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 1,
            surahName: 'الفاتحة',
            verseNumber: 1,
            arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            audioUrl: 'https://example.com/001001.mp3',
            duration: Duration(hours: 1),
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration(minutes: 30),
        isPlaying: false,
      );

      await PlaybackSessionService.saveSession(session);
      final restored = await PlaybackSessionService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.playlist[0].duration, equals(Duration(hours: 1)));
      expect(restored.currentPosition, equals(Duration(minutes: 30)));
    });
  });

  group('PlaybackSessionService Multiple Sessions', () {
    test('overwrites previous session when saving new one', () async {
      final session1 = PlaybackSession(
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
      );

      await PlaybackSessionService.saveSession(session1);

      final session2 = PlaybackSession(
        playlist: [
          const QuranVerse(
            surahNumber: 2,
            surahName: 'البقرة',
            verseNumber: 1,
            arabicText: 'الم',
            audioUrl: 'https://example.com/002001.mp3',
            duration: Duration(seconds: 3),
          ),
        ],
        currentIndex: 0,
        currentPosition: Duration(seconds: 1),
        isPlaying: true,
      );

      await PlaybackSessionService.saveSession(session2);
      final restored = await PlaybackSessionService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.playlist[0].surahNumber, equals(2));
      expect(restored.isPlaying, isTrue);
    });
  });

  group('PlaybackSessionService Error Handling', () {
    test('restoreSession handles corrupted data gracefully', () async {
      // Manually insert corrupted data
      final box = Hive.box('playback_session');
      await box.put('current_session', 'invalid json data');

      final restored = await PlaybackSessionService.restoreSession();
      expect(restored, isNull);
    });
  });
}
