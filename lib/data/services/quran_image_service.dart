import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class QuranImageService {
  // Base URL for Quran images
  static const String baseUrl =
      'https://cdn.jsdelivr.net/gh/BetimShala/quran-images-api@master/quran-images';

  // Cache for downloaded images
  final Map<int, Uint8List> _imageCache = {};

  /// Get image URL for a specific page
  String getPageImageUrl(int pageNumber) {
    return '$baseUrl/$pageNumber.png';
  }

  /// Download and cache a page image
  Future<Uint8List?> getPageImage(int pageNumber) async {
    // Check cache first
    if (_imageCache.containsKey(pageNumber)) {
      return _imageCache[pageNumber];
    }

    try {
      final url = getPageImageUrl(pageNumber);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        _imageCache[pageNumber] = imageData;
        return imageData;
      }
    } catch (e) {
      debugPrint('Error downloading page $pageNumber: $e');
    }

    return null;
  }

  /// Preload multiple pages for smoother navigation
  Future<void> preloadPages(List<int> pageNumbers) async {
    for (final pageNumber in pageNumbers) {
      if (!_imageCache.containsKey(pageNumber)) {
        await getPageImage(pageNumber);
      }
    }
  }

  /// Clear cache to free memory
  void clearCache() {
    _imageCache.clear();
  }

  /// Get cache size
  int getCacheSize() {
    return _imageCache.length;
  }
}
