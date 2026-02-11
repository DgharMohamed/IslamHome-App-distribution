import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranCdnService {
  static const String audioBaseUrl = 'https://cdn.islamic.network/quran/audio';
  static const String surahAudioBaseUrl =
      'https://cdn.islamic.network/quran/audio-surah';
  static const String imageBaseUrl = 'https://cdn.islamic.network/quran/images';

  /// Get audio URL for a specific Ayah (global number 1-6236)
  String getAyahAudioUrl(
    int globalAyahNumber, {
    String edition = 'ar.alafasy',
    int bitrate = 128,
  }) {
    return '$audioBaseUrl/$bitrate/$edition/$globalAyahNumber.mp3';
  }

  /// Get audio URL for a whole Surah
  String getSurahAudioUrl(
    int surahNumber, {
    String edition = 'ar.alafasy',
    int bitrate = 128,
  }) {
    return '$surahAudioBaseUrl/$bitrate/$edition/$surahNumber.mp3';
  }

  /// Get Ayah image URL (perfect for precise calligraphy)
  String getAyahImageUrl(int surah, int ayah, {bool highRes = true}) {
    final res = highRes ? 'high-resolution/' : '';
    return '$imageBaseUrl/$res${surah}_$ayah.png';
  }

  /// Get Al Quran Cloud full page image redirector
  String getPageImageUrl(int pageNumber) {
    return 'https://api.alquran.cloud/v1/page/$pageNumber/image';
  }
}

final quranCdnServiceProvider = Provider((ref) => QuranCdnService());
