import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/data/services/notification_manager.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';

void main() {
  group('NotificationManager Arabic Text Support', () {
    group('Text Formatting Methods', () {
      test('formatVerseInfo formats Arabic text correctly', () {
        final result = NotificationManager.formatVerseInfo('الفاتحة', 1);
        expect(result, equals('سورة الفاتحة - آية 1'));
        expect(result, contains('سورة'));
        expect(result, contains('آية'));
      });

      test('formatNotificationTitle formats title correctly', () {
        final result = NotificationManager.formatNotificationTitle(
          'الفاتحة',
          5,
        );
        expect(result, equals('الفاتحة - آية 5'));
        expect(result, contains('آية'));
      });

      test('formatNotificationArtist returns القرآن الكريم', () {
        final result = NotificationManager.formatNotificationArtist();
        expect(result, equals('القرآن الكريم'));
      });

      test('formatNotificationAlbum formats album correctly', () {
        final result = NotificationManager.formatNotificationAlbum('البقرة');
        expect(result, equals('سورة البقرة'));
        expect(result, contains('سورة'));
      });
    });

    group('MediaItem Validation', () {
      test(
        'validateMediaItemFormatting accepts properly formatted MediaItem',
        () {
          final mediaItem = MediaItem(
            id: 'test_url',
            title: 'الفاتحة - آية 1',
            artist: 'القرآن الكريم',
            album: 'سورة الفاتحة',
          );

          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isTrue,
          );
        },
      );

      test(
        'validateMediaItemFormatting rejects MediaItem without آية marker',
        () {
          final mediaItem = MediaItem(
            id: 'test_url',
            title: 'الفاتحة - 1', // Missing آية
            artist: 'القرآن الكريم',
            album: 'سورة الفاتحة',
          );

          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isFalse,
          );
        },
      );

      test(
        'validateMediaItemFormatting rejects MediaItem with wrong artist',
        () {
          final mediaItem = MediaItem(
            id: 'test_url',
            title: 'الفاتحة - آية 1',
            artist: 'Wrong Artist', // Wrong artist
            album: 'سورة الفاتحة',
          );

          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isFalse,
          );
        },
      );

      test(
        'validateMediaItemFormatting rejects MediaItem without سورة prefix',
        () {
          final mediaItem = MediaItem(
            id: 'test_url',
            title: 'الفاتحة - آية 1',
            artist: 'القرآن الكريم',
            album: 'الفاتحة', // Missing سورة prefix
          );

          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isFalse,
          );
        },
      );
    });

    group('QuranVerse MediaItem Conversion', () {
      test('QuranVerse.toMediaItem creates properly formatted MediaItem', () {
        final verse = QuranVerse(
          surahNumber: 1,
          surahName: 'الفاتحة',
          verseNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          audioUrl: 'https://example.com/audio.mp3',
          duration: const Duration(seconds: 10),
        );

        final mediaItem = verse.toMediaItem();

        // Verify title format
        expect(mediaItem.title, equals('الفاتحة - آية 1'));
        expect(mediaItem.title, contains('آية'));

        // Verify artist
        expect(mediaItem.artist, equals('القرآن الكريم'));

        // Verify album format
        expect(mediaItem.album, equals('سورة الفاتحة'));
        expect(mediaItem.album, contains('سورة'));

        // Verify extras contain all required fields
        expect(mediaItem.extras, isNotNull);
        expect(mediaItem.extras!['surahNumber'], equals(1));
        expect(mediaItem.extras!['verseNumber'], equals(1));
        expect(mediaItem.extras!['surahName'], equals('الفاتحة'));
        expect(
          mediaItem.extras!['arabicText'],
          equals('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
        );

        // Verify it passes validation
        expect(
          NotificationManager.validateMediaItemFormatting(mediaItem),
          isTrue,
        );
      });

      test(
        'QuranMediaItem.toMediaItem creates properly formatted MediaItem',
        () {
          final quranMediaItem = QuranMediaItem(
            surahNumber: 2,
            surahName: 'البقرة',
            verseNumber: 255,
            audioUrl: 'https://example.com/ayat-kursi.mp3',
            duration: const Duration(seconds: 120),
          );

          final mediaItem = quranMediaItem.toMediaItem();

          // Verify title format
          expect(mediaItem.title, equals('البقرة - آية 255'));
          expect(mediaItem.title, contains('آية'));

          // Verify artist
          expect(mediaItem.artist, equals('القرآن الكريم'));

          // Verify album format
          expect(mediaItem.album, equals('سورة البقرة'));
          expect(mediaItem.album, contains('سورة'));

          // Verify it passes validation
          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isTrue,
          );
        },
      );

      test('MediaItem formatting works with different surah names', () {
        final surahNames = [
          'الفاتحة',
          'البقرة',
          'آل عمران',
          'النساء',
          'المائدة',
          'الأنعام',
          'الإخلاص',
          'الناس',
        ];

        for (final surahName in surahNames) {
          final verse = QuranVerse(
            surahNumber: 1,
            surahName: surahName,
            verseNumber: 1,
            arabicText: 'test',
            audioUrl: 'https://example.com/audio.mp3',
            duration: const Duration(seconds: 10),
          );

          final mediaItem = verse.toMediaItem();

          // Verify all formatting is correct
          expect(mediaItem.title, contains(surahName));
          expect(mediaItem.title, contains('آية'));
          expect(mediaItem.artist, equals('القرآن الكريم'));
          expect(mediaItem.album, equals('سورة $surahName'));
          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isTrue,
          );
        }
      });

      test('MediaItem formatting works with different verse numbers', () {
        final verseNumbers = [1, 10, 100, 255, 286];

        for (final verseNumber in verseNumbers) {
          final verse = QuranVerse(
            surahNumber: 2,
            surahName: 'البقرة',
            verseNumber: verseNumber,
            arabicText: 'test',
            audioUrl: 'https://example.com/audio.mp3',
            duration: const Duration(seconds: 10),
          );

          final mediaItem = verse.toMediaItem();

          // Verify verse number is in title
          expect(mediaItem.title, contains('آية $verseNumber'));
          expect(
            NotificationManager.validateMediaItemFormatting(mediaItem),
            isTrue,
          );
        }
      });
    });
  });
}
