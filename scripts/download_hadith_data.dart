// ignore_for_file: avoid_print
import 'dart:io';

Future<void> main() async {
  final hadithDir = Directory('assets/data/hadith');
  final nawawiDir = Directory('assets/data/nawawi');

  if (!hadithDir.existsSync()) {
    hadithDir.createSync(recursive: true);
    print('Created assets/data/hadith directory');
  }
  if (!nawawiDir.existsSync()) {
    nawawiDir.createSync(recursive: true);
    print('Created assets/data/nawawi directory');
  }

  // URLs for the data
  final endpoints = {
    'assets/data/hadith/bukhari.json':
        'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-bukhari.json',
    'assets/data/nawawi/nawawi.json':
        'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-nawawi.json',
  };

  final httpClient = HttpClient();

  for (final entry in endpoints.entries) {
    final path = entry.key;
    final url = entry.value;
    final file = File(path);

    if (file.existsSync()) {
      print('$path already exists. Skipping...');
      continue;
    }

    print('Downloading ${file.uri.pathSegments.last} from $url...');
    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final sink = file.openWrite();
        await response.pipe(sink);
        await sink.close();
        print('Saved $path');
      } else {
        print('Failed to download $path: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading $path: $e');
    }
  }
  httpClient.close();
}
