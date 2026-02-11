// ignore_for_file: avoid_print
import 'dart:io';

Future<void> main() async {
  final assetsDir = Directory('assets/json');
  if (!assetsDir.existsSync()) {
    assetsDir.createSync(recursive: true);
    print('Created assets/json directory');
  }

  // URLs for the data
  // Using alquran.cloud API
  final endpoints = {
    'quran-uthmani.json': 'http://api.alquran.cloud/v1/quran/quran-uthmani',
    'en.sahih.json': 'http://api.alquran.cloud/v1/quran/en.sahih',
    'ar.jalalayn.json': 'http://api.alquran.cloud/v1/quran/ar.jalalayn',
    'surahs.json': 'http://api.alquran.cloud/v1/surah',
  };

  final httpClient = HttpClient();

  for (final entry in endpoints.entries) {
    final filename = entry.key;
    final url = entry.value;
    final file = File('${assetsDir.path}/$filename');

    if (file.existsSync()) {
      print('$filename already exists. Skipping...');
      continue;
    }

    print('Downloading $filename from $url...');
    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final sink = file.openWrite();
        await response.pipe(sink);
        await sink.close();
        print('Saved $filename');
      } else {
        print('Failed to download $filename: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading $filename: $e');
    }
  }
  httpClient.close();
}
