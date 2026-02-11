import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:audio_service/audio_service.dart';

/// Feature: quran-notification-player
/// Tests for QuranVerse and QuranMediaItem data models
/// Validates: Requirements 3.1, 3.2
///
/// These tests verify that QuranVerse and QuranMediaItem properly support
/// Arabic information (surah name, verse number) and can be correctly
/// converted to MediaItem for notification display.
void main() {
  group('QuranVerse Tests', () {
    test('QuranVerse can be created with all required fields', () {
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: 'الفاتحة',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
      );

      expect(verse.surahNumber, equals(1));
      expect(verse.surahName, equals('الفاتحة'));
      expect(verse.verseNumber, equals(1));
      expect(
        verse.arabicText,
        equals('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
      );
      expect(verse.audioUrl, equals('https://example.com/001001.mp3'));
      expect(verse.duration, equals(Duration(seconds: 5)));
      expect(verse.translation, isNull);
    });

    test('QuranVerse can be created with optional translation', () {
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: 'الفاتحة',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
        translation:
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      );

      expect(verse.translation, isNotNull);
      expect(
        verse.translation,
        equals(
          'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
      );
    });

    test(
      'QuranVerse.toMediaItem creates MediaItem with correct Arabic title format',
      () {
        // Requirement 3.1: Display surah name and verse number in notification
        const verse = QuranVerse(
          surahNumber: 2,
          surahName: 'البقرة',
          verseNumber: 255,
          arabicText: 'آية الكرسي',
          audioUrl: 'https://example.com/002255.mp3',
          duration: Duration(seconds: 120),
        );

        final mediaItem = verse.toMediaItem();

        // Verify Arabic title format: "SurahName - آية VerseNumber"
        expect(mediaItem.title, equals('البقرة - آية 255'));
        expect(mediaItem.artist, equals('القرآن الكريم'));
        expect(mediaItem.album, equals('سورة البقرة'));
        expect(mediaItem.id, equals('https://example.com/002255.mp3'));
        expect(mediaItem.duration, equals(Duration(seconds: 120)));
      },
    );

    test('QuranVerse.toMediaItem includes all data in extras', () {
      const verse = QuranVerse(
        surahNumber: 18,
        surahName: 'الكهف',
        verseNumber: 10,
        arabicText: 'إِذْ أَوَى الْفِتْيَةُ إِلَى الْكَهْفِ',
        audioUrl: 'https://example.com/018010.mp3',
        duration: Duration(seconds: 15),
        translation: 'When the youths took refuge in the cave',
      );

      final mediaItem = verse.toMediaItem();

      expect(mediaItem.extras, isNotNull);
      expect(mediaItem.extras!['surahNumber'], equals(18));
      expect(mediaItem.extras!['verseNumber'], equals(10));
      expect(mediaItem.extras!['surahName'], equals('الكهف'));
      expect(
        mediaItem.extras!['arabicText'],
        equals('إِذْ أَوَى الْفِتْيَةُ إِلَى الْكَهْفِ'),
      );
      expect(
        mediaItem.extras!['translation'],
        equals('When the youths took refuge in the cave'),
      );
    });

    test('QuranVerse.toMediaItem handles null translation correctly', () {
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: 'الفاتحة',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
        translation: null,
      );

      final mediaItem = verse.toMediaItem();

      expect(mediaItem.extras!['translation'], isNull);
    });

    test('QuranVerse.fromMediaItem correctly reconstructs QuranVerse', () {
      const originalVerse = QuranVerse(
        surahNumber: 36,
        surahName: 'يس',
        verseNumber: 1,
        arabicText: 'يس',
        audioUrl: 'https://example.com/036001.mp3',
        duration: Duration(seconds: 3),
        translation: 'Ya-Seen',
      );

      final mediaItem = originalVerse.toMediaItem();
      final reconstructedVerse = QuranVerse.fromMediaItem(mediaItem);

      expect(reconstructedVerse.surahNumber, equals(originalVerse.surahNumber));
      expect(reconstructedVerse.surahName, equals(originalVerse.surahName));
      expect(reconstructedVerse.verseNumber, equals(originalVerse.verseNumber));
      expect(reconstructedVerse.arabicText, equals(originalVerse.arabicText));
      expect(reconstructedVerse.audioUrl, equals(originalVerse.audioUrl));
      expect(reconstructedVerse.duration, equals(originalVerse.duration));
      expect(reconstructedVerse.translation, equals(originalVerse.translation));
    });

    test('QuranVerse.fromMediaItem handles missing duration', () {
      final mediaItem = MediaItem(
        id: 'https://example.com/001001.mp3',
        title: 'الفاتحة - آية 1',
        artist: 'القرآن الكريم',
        album: 'سورة الفاتحة',
        duration: null, // No duration
        extras: {
          'surahNumber': 1,
          'verseNumber': 1,
          'surahName': 'الفاتحة',
          'arabicText': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'translation': null,
        },
      );

      final verse = QuranVerse.fromMediaItem(mediaItem);

      expect(verse.duration, equals(Duration.zero));
    });

    test('QuranVerse handles different surah names correctly', () {
      final surahNames = [
        'الفاتحة',
        'البقرة',
        'آل عمران',
        'النساء',
        'المائدة',
        'الأنعام',
        'الأعراف',
        'الأنفال',
        'التوبة',
        'يونس',
      ];

      for (var i = 0; i < surahNames.length; i++) {
        final verse = QuranVerse(
          surahNumber: i + 1,
          surahName: surahNames[i],
          verseNumber: 1,
          arabicText: 'نص الآية',
          audioUrl:
              'https://example.com/${(i + 1).toString().padLeft(3, '0')}001.mp3',
          duration: Duration(seconds: 5),
        );

        final mediaItem = verse.toMediaItem();

        expect(mediaItem.title, equals('${surahNames[i]} - آية 1'));
        expect(mediaItem.album, equals('سورة ${surahNames[i]}'));
      }
    });

    test('QuranVerse handles large verse numbers correctly', () {
      // Al-Baqarah has 286 verses
      const verse = QuranVerse(
        surahNumber: 2,
        surahName: 'البقرة',
        verseNumber: 286,
        arabicText: 'آخر آية في سورة البقرة',
        audioUrl: 'https://example.com/002286.mp3',
        duration: Duration(seconds: 60),
      );

      final mediaItem = verse.toMediaItem();

      expect(mediaItem.title, equals('البقرة - آية 286'));
      expect(mediaItem.extras!['verseNumber'], equals(286));
    });

    test('QuranVerse handles zero duration', () {
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: 'الفاتحة',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration.zero,
      );

      final mediaItem = verse.toMediaItem();

      expect(mediaItem.duration, equals(Duration.zero));
    });
  });

  group('QuranMediaItem Tests', () {
    test('QuranMediaItem can be created with all required fields', () {
      const mediaItem = QuranMediaItem(
        surahName: 'الفاتحة',
        surahNumber: 1,
        verseNumber: 1,
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
      );

      expect(mediaItem.surahName, equals('الفاتحة'));
      expect(mediaItem.surahNumber, equals(1));
      expect(mediaItem.verseNumber, equals(1));
      expect(mediaItem.audioUrl, equals('https://example.com/001001.mp3'));
      expect(mediaItem.duration, equals(Duration(seconds: 5)));
      expect(mediaItem.artworkUrl, isNull);
    });

    test('QuranMediaItem can be created with optional artwork URL', () {
      const mediaItem = QuranMediaItem(
        surahName: 'الفاتحة',
        surahNumber: 1,
        verseNumber: 1,
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
        artworkUrl: 'https://example.com/artwork.png',
      );

      expect(mediaItem.artworkUrl, equals('https://example.com/artwork.png'));
    });

    test(
      'QuranMediaItem.toMediaItem creates MediaItem with correct Arabic format',
      () {
        // Requirement 3.1: Display surah name and verse number in notification
        const quranMediaItem = QuranMediaItem(
          surahName: 'الإخلاص',
          surahNumber: 112,
          verseNumber: 1,
          audioUrl: 'https://example.com/112001.mp3',
          duration: Duration(seconds: 3),
        );

        final mediaItem = quranMediaItem.toMediaItem();

        expect(mediaItem.title, equals('الإخلاص - آية 1'));
        expect(mediaItem.artist, equals('القرآن الكريم'));
        expect(mediaItem.album, equals('سورة الإخلاص'));
        expect(mediaItem.id, equals('https://example.com/112001.mp3'));
        expect(mediaItem.duration, equals(Duration(seconds: 3)));
        expect(mediaItem.artUri, isNull);
      },
    );

    test('QuranMediaItem.toMediaItem includes artwork URI when provided', () {
      const quranMediaItem = QuranMediaItem(
        surahName: 'الفاتحة',
        surahNumber: 1,
        verseNumber: 1,
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
        artworkUrl: 'https://example.com/quran_artwork.png',
      );

      final mediaItem = quranMediaItem.toMediaItem();

      expect(mediaItem.artUri, isNotNull);
      expect(
        mediaItem.artUri.toString(),
        equals('https://example.com/quran_artwork.png'),
      );
    });

    test('QuranMediaItem.toMediaItem includes all data in extras', () {
      const quranMediaItem = QuranMediaItem(
        surahName: 'الكوثر',
        surahNumber: 108,
        verseNumber: 1,
        audioUrl: 'https://example.com/108001.mp3',
        duration: Duration(seconds: 2),
      );

      final mediaItem = quranMediaItem.toMediaItem();

      expect(mediaItem.extras, isNotNull);
      expect(mediaItem.extras!['surahNumber'], equals(108));
      expect(mediaItem.extras!['verseNumber'], equals(1));
      expect(mediaItem.extras!['surahName'], equals('الكوثر'));
    });

    test('QuranMediaItem handles different surah names correctly', () {
      final testCases = [
        {'name': 'الفاتحة', 'number': 1},
        {'name': 'البقرة', 'number': 2},
        {'name': 'الناس', 'number': 114},
      ];

      for (final testCase in testCases) {
        final quranMediaItem = QuranMediaItem(
          surahName: testCase['name'] as String,
          surahNumber: testCase['number'] as int,
          verseNumber: 1,
          audioUrl: 'https://example.com/audio.mp3',
          duration: Duration(seconds: 5),
        );

        final mediaItem = quranMediaItem.toMediaItem();

        expect(mediaItem.title, equals('${testCase['name']} - آية 1'));
        expect(mediaItem.album, equals('سورة ${testCase['name']}'));
      }
    });
  });

  group('QuranVerse and QuranMediaItem Integration Tests', () {
    test('Both classes produce equivalent MediaItems for same verse', () {
      // Requirement 3.2: Display surah name and current verse for full surah playback
      const verse = QuranVerse(
        surahNumber: 55,
        surahName: 'الرحمن',
        verseNumber: 13,
        arabicText: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
        audioUrl: 'https://example.com/055013.mp3',
        duration: Duration(seconds: 8),
      );

      const mediaItem = QuranMediaItem(
        surahName: 'الرحمن',
        surahNumber: 55,
        verseNumber: 13,
        audioUrl: 'https://example.com/055013.mp3',
        duration: Duration(seconds: 8),
      );

      final verseMediaItem = verse.toMediaItem();
      final quranMediaItem = mediaItem.toMediaItem();

      // Both should produce the same title and album
      expect(verseMediaItem.title, equals(quranMediaItem.title));
      expect(verseMediaItem.album, equals(quranMediaItem.album));
      expect(verseMediaItem.artist, equals(quranMediaItem.artist));
      expect(verseMediaItem.id, equals(quranMediaItem.id));
      expect(verseMediaItem.duration, equals(quranMediaItem.duration));
    });

    test('QuranVerse provides more detailed information than QuranMediaItem', () {
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: 'الفاتحة',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
        translation:
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      );

      final verseMediaItem = verse.toMediaItem();

      // QuranVerse includes arabicText and translation in extras
      expect(verseMediaItem.extras!['arabicText'], isNotNull);
      expect(verseMediaItem.extras!['translation'], isNotNull);
    });

    test('MediaItems from both classes work with AudioService', () {
      // This test verifies that both classes produce valid MediaItems
      // that can be used with AudioService
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: 'الفاتحة',
        verseNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
      );

      const mediaItem = QuranMediaItem(
        surahName: 'الفاتحة',
        surahNumber: 1,
        verseNumber: 1,
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
      );

      final verseMediaItem = verse.toMediaItem();
      final quranMediaItem = mediaItem.toMediaItem();

      // Both should have all required MediaItem fields
      expect(verseMediaItem.id, isNotEmpty);
      expect(verseMediaItem.title, isNotEmpty);
      expect(quranMediaItem.id, isNotEmpty);
      expect(quranMediaItem.title, isNotEmpty);
    });
  });

  group('Edge Cases and Error Handling', () {
    test('QuranVerse handles empty strings gracefully', () {
      const verse = QuranVerse(
        surahNumber: 1,
        surahName: '',
        verseNumber: 1,
        arabicText: '',
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
      );

      final mediaItem = verse.toMediaItem();

      expect(mediaItem.title, equals(' - آية 1'));
      expect(mediaItem.album, equals('سورة '));
    });

    test('QuranVerse handles very long Arabic text', () {
      final longText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ' * 100;
      final verse = QuranVerse(
        surahNumber: 2,
        surahName: 'البقرة',
        verseNumber: 282, // Longest verse in Quran
        arabicText: longText,
        audioUrl: 'https://example.com/002282.mp3',
        duration: Duration(minutes: 5),
      );

      final mediaItem = verse.toMediaItem();

      expect(mediaItem.extras!['arabicText'], equals(longText));
      expect(mediaItem.extras!['arabicText'].length, greaterThan(1000));
    });

    test('QuranMediaItem handles invalid artwork URL format', () {
      const mediaItem = QuranMediaItem(
        surahName: 'الفاتحة',
        surahNumber: 1,
        verseNumber: 1,
        audioUrl: 'https://example.com/001001.mp3',
        duration: Duration(seconds: 5),
        artworkUrl: 'not-a-valid-url',
      );

      // Should not throw an exception
      expect(() => mediaItem.toMediaItem(), returnsNormally);
    });

    test('QuranVerse roundtrip conversion preserves all data', () {
      const original = QuranVerse(
        surahNumber: 67,
        surahName: 'الملك',
        verseNumber: 15,
        arabicText: 'هُوَ الَّذِي جَعَلَ لَكُمُ الْأَرْضَ ذَلُولًا',
        audioUrl: 'https://example.com/067015.mp3',
        duration: Duration(seconds: 12),
        translation: 'It is He who made the earth tame for you',
      );

      final mediaItem = original.toMediaItem();
      final reconstructed = QuranVerse.fromMediaItem(mediaItem);

      // Verify all fields are preserved
      expect(reconstructed.surahNumber, equals(original.surahNumber));
      expect(reconstructed.surahName, equals(original.surahName));
      expect(reconstructed.verseNumber, equals(original.verseNumber));
      expect(reconstructed.arabicText, equals(original.arabicText));
      expect(reconstructed.audioUrl, equals(original.audioUrl));
      expect(reconstructed.duration, equals(original.duration));
      expect(reconstructed.translation, equals(original.translation));
    });
  });
}
