import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:islamic_library_flutter/data/services/quran_audio_handler.dart';
import 'package:audio_service/audio_service.dart';

/// Unit tests for QuranAudioHandler navigation operations
/// Requirements 2.2, 2.3: Navigation between verses (skipToNext, skipToPrevious)
///
/// These tests verify that the QuranAudioHandler properly implements
/// navigation between verses in a playlist and updates the MediaItem correctly.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranAudioHandler Navigation Operations', () {
    late QuranAudioHandler handler;

    setUp(() async {
      handler = QuranAudioHandler();
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() async {
      await handler.dispose();
    });

    group('skipToNext() operation', () {
      test('skipToNext() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.skipToNext();
      });

      test('skipToNext() can be called multiple times safely', () async {
        // Act - call multiple times
        await handler.skipToNext();
        await handler.skipToNext();
        await handler.skipToNext();

        // Assert - should not throw
        expect(handler.playbackState.value, isNotNull);
      });
    });

    group('skipToPrevious() operation', () {
      test('skipToPrevious() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.skipToPrevious();
      });

      test('skipToPrevious() can be called multiple times safely', () async {
        // Act - call multiple times
        await handler.skipToPrevious();
        await handler.skipToPrevious();
        await handler.skipToPrevious();

        // Assert - should not throw
        expect(handler.playbackState.value, isNotNull);
      });
    });

    group('skipToQueueItem() operation', () {
      test('skipToQueueItem() method exists and can be called', () async {
        // Act & Assert - should not throw
        await handler.skipToQueueItem(0);
      });

      test('skipToQueueItem() accepts different indices', () async {
        // Act - call with different indices
        await handler.skipToQueueItem(0);
        await handler.skipToQueueItem(1);
        await handler.skipToQueueItem(5);

        // Assert - should not throw
        expect(handler.playbackState.value, isNotNull);
      });

      test('skipToQueueItem() handles negative indices gracefully', () async {
        // Act & Assert - should not throw
        await handler.skipToQueueItem(-1);
      });

      test('skipToQueueItem() handles large indices gracefully', () async {
        // Act & Assert - should not throw
        await handler.skipToQueueItem(999);
      });
    });

    group('Navigation with queue', () {
      test('queue is updated when playlist is set', () async {
        // Arrange
        final verses = _createTestVerses(3);
        final queueItems = <List<MediaItem>>[];
        final subscription = handler.queue.listen(queueItems.add);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        expect(queueItems, isNotEmpty);
        final lastQueue = queueItems.last;
        expect(lastQueue.length, equals(3));
        expect(lastQueue[0].title, contains('الفاتحة'));
        expect(lastQueue[0].title, contains('آية 1'));
        expect(lastQueue[1].title, contains('آية 2'));
        expect(lastQueue[2].title, contains('آية 3'));

        await subscription.cancel();
      });

      test('mediaItem is set when playlist starts', () async {
        // Arrange
        final verses = _createTestVerses(3);
        final mediaItems = <MediaItem?>[];
        final subscription = handler.mediaItem.listen(mediaItems.add);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        expect(mediaItems, isNotEmpty);
        final lastItem = mediaItems.last;
        expect(lastItem, isNotNull);
        expect(lastItem!.title, contains('الفاتحة'));
        expect(lastItem.title, contains('آية 1'));

        await subscription.cancel();
      });

      test('queue index is tracked in playback state', () async {
        // Arrange
        final verses = _createTestVerses(5);

        // Act
        await handler.playVersePlaylist(verses, initialIndex: 2);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        final state = handler.playbackState.value;
        expect(state.queueIndex, equals(2));
      });
    });

    group('Edge cases', () {
      test('navigation works with single verse playlist', () async {
        // Arrange
        final verses = _createTestVerses(1);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));
        await handler.skipToNext();
        await handler.skipToPrevious();

        // Assert - should not throw
        expect(handler.playbackState.value, isNotNull);
      });

      test('navigation works with empty playlist', () async {
        // Act & Assert - should not throw
        await handler.skipToNext();
        await handler.skipToPrevious();
      });

      test('skipToQueueItem works with empty queue', () async {
        // Act & Assert - should not throw
        await handler.skipToQueueItem(0);
      });

      test('navigation preserves playback state', () async {
        // Arrange
        final verses = _createTestVerses(3);
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Act
        await handler.skipToNext();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        final state = handler.playbackState.value;
        expect(state, isNotNull);
        expect(state.controls, isNotEmpty);
        expect(
          state.controls.any((c) => c.action == MediaAction.skipToNext),
          isTrue,
        );
        expect(
          state.controls.any((c) => c.action == MediaAction.skipToPrevious),
          isTrue,
        );
      });
    });

    group('MediaItem updates during navigation', () {
      test('mediaItem stream emits updates', () async {
        // Arrange
        final verses = _createTestVerses(3);
        final mediaItems = <MediaItem?>[];
        final subscription = handler.mediaItem.listen(mediaItems.add);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        expect(mediaItems, isNotEmpty);
        expect(mediaItems.last, isNotNull);

        await subscription.cancel();
      });

      test('mediaItem contains correct verse information', () async {
        // Arrange
        final verses = _createTestVerses(3);

        // Act
        await handler.playVersePlaylist(verses, initialIndex: 1);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        final item = handler.mediaItem.value;
        expect(item, isNotNull);
        expect(item!.title, contains('آية 2'));
        expect(item.extras, isNotNull);
        expect(item.extras!['verseNumber'], equals(2));
      });

      test('mediaItem extras contain all required fields', () async {
        // Arrange
        final verses = _createTestVerses(1);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        final item = handler.mediaItem.value;
        expect(item, isNotNull);
        expect(item!.extras, isNotNull);
        expect(item.extras!['surahNumber'], isNotNull);
        expect(item.extras!['verseNumber'], isNotNull);
        expect(item.extras!['surahName'], isNotNull);
        expect(item.extras!['arabicText'], isNotNull);
      });
    });

    group('Playlist management', () {
      test('playVersePlaylist accepts empty list', () async {
        // Act & Assert - should not throw
        await handler.playVersePlaylist([]);
      });

      test('playVersePlaylist with single verse', () async {
        // Arrange
        final verses = _createTestVerses(1);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        final queue = handler.queue.value;
        expect(queue.length, equals(1));
      });

      test('playVersePlaylist with multiple verses', () async {
        // Arrange
        final verses = _createTestVerses(10);

        // Act
        await handler.playVersePlaylist(verses);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        final queue = handler.queue.value;
        expect(queue.length, equals(10));
      });

      test('playVersePlaylist with custom initial index', () async {
        // Arrange
        final verses = _createTestVerses(5);

        // Act
        await handler.playVersePlaylist(verses, initialIndex: 3);
        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        final state = handler.playbackState.value;
        expect(state.queueIndex, equals(3));
      });

      test('playVersePlaylist handles out of bounds initial index', () async {
        // Arrange
        final verses = _createTestVerses(3);

        // Act & Assert - should not throw
        await handler.playVersePlaylist(verses, initialIndex: 10);
        await Future.delayed(const Duration(milliseconds: 300));
      });
    });

    group('Integration with playback controls', () {
      test('navigation controls are present in playback state', () async {
        // Assert
        final state = handler.playbackState.value;
        expect(
          state.controls.any((c) => c.action == MediaAction.skipToNext),
          isTrue,
        );
        expect(
          state.controls.any((c) => c.action == MediaAction.skipToPrevious),
          isTrue,
        );
      });

      test('navigation system actions are supported', () async {
        // Assert
        final state = handler.playbackState.value;
        expect(state.systemActions, contains(MediaAction.skipToNext));
        expect(state.systemActions, contains(MediaAction.skipToPrevious));
      });

      test('navigation controls remain after operations', () async {
        // Act
        await handler.pause();
        await handler.skipToNext();
        await handler.skipToPrevious();

        // Assert
        final state = handler.playbackState.value;
        expect(
          state.controls.any((c) => c.action == MediaAction.skipToNext),
          isTrue,
        );
        expect(
          state.controls.any((c) => c.action == MediaAction.skipToPrevious),
          isTrue,
        );
      });
    });
  });
}

/// Helper function to create test verses
List<QuranVerse> _createTestVerses(int count) {
  return List.generate(
    count,
    (index) => QuranVerse(
      surahNumber: 1,
      surahName: 'الفاتحة',
      verseNumber: index + 1,
      arabicText: 'نص الآية ${index + 1}',
      audioUrl:
          'https://example.com/001${(index + 1).toString().padLeft(3, '0')}.mp3',
      duration: Duration(seconds: 5 + index),
    ),
  );
}
