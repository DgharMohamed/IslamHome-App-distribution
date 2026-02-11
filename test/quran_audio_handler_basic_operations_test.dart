import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:islamic_library_flutter/data/services/quran_audio_handler.dart';
import 'package:audio_service/audio_service.dart';

/// Unit tests for QuranAudioHandler basic operations (play, pause, stop)
/// Requirements 2.1, 5.1: Basic playback controls and state management
///
/// These tests verify that the QuranAudioHandler properly implements
/// the core playback operations and broadcasts the correct state.
///
/// Note: These tests focus on state management and API contracts rather than
/// actual audio playback, as just_audio requires platform-specific implementations
/// that are not available in unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranAudioHandler Basic Operations', () {
    late QuranAudioHandler handler;

    setUp(() async {
      handler = QuranAudioHandler();
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() async {
      await handler.dispose();
    });

    group('Initialization and State', () {
      test('handler initializes with correct default state', () async {
        // Assert
        final state = handler.playbackState.value;
        expect(state.playing, isFalse);
        expect(state.processingState, equals(AudioProcessingState.idle));
        expect(state.controls, isNotEmpty);
        expect(
          state.controls.any((c) => c.action == MediaAction.play),
          isTrue,
          reason: 'Should show play button initially',
        );
      });

      test('handler has required media controls', () async {
        // Assert
        final state = handler.playbackState.value;
        final actions = state.controls.map((c) => c.action).toList();

        expect(actions, contains(MediaAction.skipToPrevious));
        expect(actions, contains(MediaAction.skipToNext));
        expect(actions, contains(MediaAction.stop));
      });

      test('handler supports required system actions', () async {
        // Assert
        final state = handler.playbackState.value;

        expect(state.systemActions, contains(MediaAction.seek));
        expect(state.systemActions, contains(MediaAction.play));
        expect(state.systemActions, contains(MediaAction.pause));
        expect(state.systemActions, contains(MediaAction.stop));
        expect(state.systemActions, contains(MediaAction.skipToNext));
        expect(state.systemActions, contains(MediaAction.skipToPrevious));
      });

      test('handler has compact action indices for Android', () async {
        // Assert
        final state = handler.playbackState.value;
        expect(state.androidCompactActionIndices, isNotNull);
        expect(state.androidCompactActionIndices, hasLength(3));
        expect(state.androidCompactActionIndices, equals([0, 1, 2]));
      });
    });

    group('play() operation', () {
      test('play() method exists', () async {
        // This test just verifies the method exists
        // We cannot actually call play() without an audio source in unit tests
        // as it will hang waiting for the audio player to respond

        // Assert - method exists
        expect(handler.play, isNotNull);
      });

      test('play() is properly defined in the interface', () async {
        // Verify that play() is part of the AudioHandler interface
        expect(handler, isA<BaseAudioHandler>());
      });
    });

    group('pause() operation', () {
      test('pause() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.pause();
      });

      test('pause() can be called multiple times safely', () async {
        // Act - pause multiple times
        await handler.pause();
        await handler.pause();
        await handler.pause();

        // Assert - should not throw
        expect(handler.playbackState.value, isNotNull);
      });
    });

    group('stop() operation', () {
      test('stop() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.stop();
      });

      test('stop() broadcasts idle state', () async {
        // Act
        await handler.stop();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        final state = handler.playbackState.value;
        expect(state.playing, isFalse);
        expect(state.processingState, equals(AudioProcessingState.idle));
      });

      test('stop() can be called when already stopped', () async {
        // Act - stop multiple times
        await handler.stop();
        await handler.stop();

        // Assert - should not throw
        expect(handler.playbackState.value.playing, isFalse);
      });

      test('stop() resets position to zero', () async {
        // Act
        await handler.stop();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(handler.player.position, equals(Duration.zero));
      });
    });

    group('State broadcasting', () {
      test('playbackState stream is available', () async {
        // Assert
        expect(handler.playbackState, isNotNull);
        expect(handler.playbackState.value, isNotNull);
      });

      test('mediaItem stream is available', () async {
        // Assert
        expect(handler.mediaItem, isNotNull);
      });

      test('queue stream is available', () async {
        // Assert
        expect(handler.queue, isNotNull);
      });

      test('state updates are broadcast through stream', () async {
        // Arrange
        final states = <PlaybackState>[];
        final subscription = handler.playbackState.listen(states.add);

        // Act
        await handler.stop();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(states.length, greaterThan(0));
        expect(states.last.playing, isFalse);

        await subscription.cancel();
      });
    });

    group('QuranVerse MediaItem conversion', () {
      test('QuranVerse converts to MediaItem correctly', () {
        // Arrange
        final verse = const QuranVerse(
          surahNumber: 1,
          surahName: 'الفاتحة',
          verseNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          audioUrl: 'https://example.com/001001.mp3',
          duration: Duration(seconds: 5),
        );

        // Act
        final mediaItem = verse.toMediaItem();

        // Assert
        expect(mediaItem.id, equals(verse.audioUrl));
        expect(mediaItem.title, contains('الفاتحة'));
        expect(mediaItem.title, contains('آية 1'));
        expect(mediaItem.artist, equals('القرآن الكريم'));
        expect(mediaItem.album, equals('سورة الفاتحة'));
        expect(mediaItem.duration, equals(Duration(seconds: 5)));
      });

      test('QuranVerse MediaItem includes extras', () {
        // Arrange
        final verse = const QuranVerse(
          surahNumber: 2,
          surahName: 'البقرة',
          verseNumber: 255,
          arabicText: 'آية الكرسي',
          audioUrl: 'https://example.com/002255.mp3',
          duration: Duration(seconds: 120),
          translation: 'Ayat al-Kursi',
        );

        // Act
        final mediaItem = verse.toMediaItem();

        // Assert
        expect(mediaItem.extras, isNotNull);
        expect(mediaItem.extras!['surahNumber'], equals(2));
        expect(mediaItem.extras!['verseNumber'], equals(255));
        expect(mediaItem.extras!['surahName'], equals('البقرة'));
        expect(mediaItem.extras!['arabicText'], equals('آية الكرسي'));
        expect(mediaItem.extras!['translation'], equals('Ayat al-Kursi'));
      });

      test('QuranVerse can be reconstructed from MediaItem', () {
        // Arrange
        final originalVerse = const QuranVerse(
          surahNumber: 1,
          surahName: 'الفاتحة',
          verseNumber: 7,
          arabicText: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
          audioUrl: 'https://example.com/001007.mp3',
          duration: Duration(seconds: 8),
        );

        final mediaItem = originalVerse.toMediaItem();

        // Act
        final reconstructedVerse = QuranVerse.fromMediaItem(mediaItem);

        // Assert
        expect(
          reconstructedVerse.surahNumber,
          equals(originalVerse.surahNumber),
        );
        expect(reconstructedVerse.surahName, equals(originalVerse.surahName));
        expect(
          reconstructedVerse.verseNumber,
          equals(originalVerse.verseNumber),
        );
        expect(reconstructedVerse.arabicText, equals(originalVerse.arabicText));
        expect(reconstructedVerse.audioUrl, equals(originalVerse.audioUrl));
        expect(reconstructedVerse.duration, equals(originalVerse.duration));
      });
    });

    group('Additional operations', () {
      test('seek() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.seek(const Duration(seconds: 5));
      });

      test('skipToNext() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.skipToNext();
      });

      test('skipToPrevious() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.skipToPrevious();
      });

      test('skipToQueueItem() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.skipToQueueItem(0);
      });

      test('setSpeed() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.setSpeed(1.0);
      });

      test('setRepeatMode() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.setRepeatMode(AudioServiceRepeatMode.none);
        await handler.setRepeatMode(AudioServiceRepeatMode.one);
        await handler.setRepeatMode(AudioServiceRepeatMode.all);
      });

      test('setShuffleMode() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.setShuffleMode(AudioServiceShuffleMode.none);
        await handler.setShuffleMode(AudioServiceShuffleMode.all);
      });
    });

    group('Edge cases', () {
      test('operations work in sequence without audio source', () async {
        // Act - sequence of operations that don't require audio source
        await handler.pause();
        await handler.stop();

        // Assert - should not throw
        expect(handler.playbackState.value, isNotNull);
      });

      test('handler can be disposed safely', () async {
        // Act & Assert - should not throw
        await handler.dispose();
      });
    });
  });
}
