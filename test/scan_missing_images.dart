import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() async {
  debugPrint('Scanning for missing reciter images...');

  // 1. Get local images
  final dir = Directory('assets/images/reciters');
  if (!await dir.exists()) {
    debugPrint('Error: assets/images/reciters directory not found.');
    return;
  }

  final files = await dir.list().toList();
  final localIds = files
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last.split('.').first)
      .where((s) => int.tryParse(s) != null)
      .map(int.parse)
      .toSet();

  debugPrint('Found ${localIds.length} local images.');

  // 2. Fetch API reciters
  final url = Uri.parse('https://mp3quran.net/api/v3/reciters?language=ar');
  try {
    final response = await http.get(url);
    if (response.statusCode != 200) {
      debugPrint('Error fetching reciters: ${response.statusCode}');
      return;
    }

    final data = json.decode(response.body);
    final List<dynamic> reciters = data['reciters'];

    final apiIds = reciters.map((r) => r['id'] as int).toSet();
    debugPrint('Found ${apiIds.length} reciters from API.');

    // 3. Find missing
    final missingIds = apiIds.difference(localIds).toList()..sort();

    if (missingIds.isEmpty) {
      debugPrint('All reciters have images!');
    } else {
      debugPrint('Missing images for ${missingIds.length} reciters:');
      debugPrint(missingIds.join(', '));

      // Optional: Print names for context
      debugPrint('\nMissing Reciter Names:');
      for (var id in missingIds) {
        final reciter = reciters.firstWhere((r) => r['id'] == id);
        debugPrint('$id: ${reciter['name']}');
      }
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}
