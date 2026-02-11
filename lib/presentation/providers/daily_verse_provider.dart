import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyVerse {
  final String text;
  final String surah;
  final String translation;

  DailyVerse({
    required this.text,
    required this.surah,
    required this.translation,
  });
}

final dailyVerseProvider = Provider<DailyVerse>((ref) {
  final now = DateTime.now();
  // Using day of the year to ensure it changes daily
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

  final verses = [
    DailyVerse(
      text: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      surah: "سورة الشرح",
      translation:
          "For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.",
    ),
    DailyVerse(
      text: "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
      surah: "سورة البقرة",
      translation:
          "So remember Me; I will remember you. And be grateful to Me and do not deny Me.",
    ),
    DailyVerse(
      text: "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
      surah: "سورة البقرة",
      translation:
          "Allah does not charge a soul except [with that within] its capacity.",
    ),
    DailyVerse(
      text:
          "قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَى أَنْفُسِهِمْ لَا تَقْنَطُوا مِنْ رَحْمَةِ اللَّهِ",
      surah: "سورة الزمر",
      translation:
          "Say, \"O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah.\"",
    ),
    DailyVerse(
      text: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      surah: "سورة الرعد",
      translation:
          "Unquestionably, by the remembrance of Allah hearts are assured.",
    ),
    DailyVerse(
      text: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ",
      surah: "سورة البقرة",
      translation:
          "And when My servants ask you, [O Muhammad], concerning Me - indeed I am near.",
    ),
    DailyVerse(
      text: "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
      surah: "سورة البقرة",
      translation: "Indeed, Allah is with the patient.",
    ),
    DailyVerse(
      text: "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا",
      surah: "سورة الطلاق",
      translation: "And whoever fears Allah - He will make for him a way out.",
    ),
    DailyVerse(
      text: "وَقُل رَّبِّ زِدْنِي عِلْمًا",
      surah: "سورة طه",
      translation: "And say, \"My Lord, increase me in knowledge.\"",
    ),
    DailyVerse(
      text:
          "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      surah: "سورة البقرة",
      translation:
          "Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.",
    ),
  ];

  return verses[dayOfYear % verses.length];
});
