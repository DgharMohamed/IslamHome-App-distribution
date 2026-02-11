import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_library_flutter/core/utils/quran_utils.dart';
import 'package:islamic_library_flutter/data/models/quran_content_model.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';
import 'package:islamic_library_flutter/presentation/widgets/ayah_tile.dart';

void main() {
  group('QuranUtils Tests', () {
    test('isArabic identifies Arabic text correctly', () {
      expect(QuranUtils.isArabic('بسم الله'), isTrue);
      expect(QuranUtils.isArabic('Hello World'), isFalse);
      expect(
        QuranUtils.isArabic('Mixed text عربي'),
        isTrue,
      ); // Should be true if it contains Arabic
    });
  });

  group('AyahTile Widget Tests', () {
    testWidgets('renders Arabic and Translation text', (
      WidgetTester tester,
    ) async {
      // Mock Data
      final surah = Surah(
        number: 1,
        name: 'الفاتحة',
        englishName: 'Al-Fatiha',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
      );
      final arabicAyah = Ayah(
        number: 1,
        text: 'بسم الله الرحمن الرحيم',
        numberInSurah: 1,
        juz: 1,
        manzil: 1,
        page: 1,
        ruku: 1,
        hizbQuarter: 1,
        surah: surah,
      );
      final transAyah = Ayah(
        number: 1,
        text:
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        numberInSurah: 1,
        surah: surah,
      );

      // Pump Widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AyahTile(
              arabicAyah: arabicAyah,
              transAyah: transAyah,
              onDetailsTap: () {},
              onShareTap: () {},
              onBookmarkTap: () {},
            ),
          ),
        ),
      );

      // Expectations
      expect(find.text('بسم الله الرحمن الرحيم'), findsOneWidget);
      expect(
        find.text(
          'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('${arabicAyah.numberInSurah}'),
        findsOneWidget,
      ); // Badge number
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });
  });
}
